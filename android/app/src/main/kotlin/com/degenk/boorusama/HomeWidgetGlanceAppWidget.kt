package com.degenk.boorusama

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Color.Companion.Black
import androidx.compose.ui.graphics.Color.Companion.White
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.Action
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import org.json.JSONArray
import org.json.JSONObject

data class ConfigData(
  val id: String,
  val name: String,
  val url: String,
  val shortName: String,
) {
  companion object {
    fun fromJson(json: Map<String, Any>): ConfigData {
      return ConfigData(
        id = json["id"] as String,
        name = json["name"] as String,
        url = json["url"] as String,
        shortName = json["shortName"] as String,
      )
    }
  }


  // intent url
    fun toUri(): Uri {
       // use id as the path
         return Uri.parse("boorusama://?cid=$id")
    }
}

class HomeWidgetGlanceAppWidget : GlanceAppWidget() {

  /** Needed for Updating */
  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  private fun getWidgetData(context: Context, preferences: SharedPreferences): List<ConfigData?> {

    // Read JSON array string
    val widgetsJson = preferences.getString("widgets_data", "[]")

    try {
      val widgets = JSONArray(widgetsJson)
      val widgetData = mutableListOf<ConfigData?>()
      for (i in 0 until widgets.length()) {
        val widget = widgets.getJSONObject(i)
        widgetData.add(ConfigData.fromJson(widget.toMap()))
      }
      return widgetData
    } catch (e: Exception) {
      e.printStackTrace()

    } catch (e: Exception) {
      e.printStackTrace()
    }

    return emptyList()
  }


  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { GlanceContent(context, currentState()) }
  }

  @Composable
  private fun GlanceContent(
    context: Context,
    currentState: HomeWidgetGlanceState,
  ) {
    val data = currentState.preferences
    val widgetData = getWidgetData(context, data)

    Box(
      modifier = GlanceModifier.background(Color(0xFF262627))
        .padding(8.dp)
    ) {
      if (widgetData.isEmpty()) {
        Text(
          "No profile added",
          style = TextStyle(fontSize = 18.sp, fontWeight = FontWeight.Bold),
          modifier = GlanceModifier.padding(8.dp)
        )
      } else {
        Column(
          modifier = GlanceModifier.padding(horizontal = 8.dp)
            .fillMaxSize(),
          verticalAlignment = Alignment.Vertical.CenterVertically,
          horizontalAlignment = Alignment.Horizontal.CenterHorizontally
        ) {
          widgetData.forEachIndexed { index, config ->
            config?.let {
              ConfigBox(
                config,
                actionLaunchUri(config.toUri())
              )
              Spacer(modifier = GlanceModifier.height(8.dp))
            }
          }
        }
      }
    }
  }

  @Composable
  private  fun ConfigBox(
    config: ConfigData = ConfigData("1", "Example", "https://example.com", "E"),
    onClick: Action = emptyAction()
  ) {
    Box(
      modifier = GlanceModifier
        .padding(8.dp)
        .cornerRadius(8.dp)
        .background(Black)
        .fillMaxWidth()
        .clickable(onClick = onClick)
    ) {
      Text(
        config.name,
        style = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.Normal, color = ColorProvider(
          White
        ),),
        modifier = GlanceModifier.padding(4.dp)
      )
    }
  }
}

fun emptyAction(): Action {
  return actionLaunchUri()
}

fun actionLaunchUri(uri: Uri? = null): Action {
  val intent = Intent(Intent.ACTION_VIEW, uri)
  return actionStartActivity(intent)
}

private fun JSONObject.toMap(): Map<String, Any> {
    val map = mutableMapOf<String, Any>()
    for (key in keys()) {
        map[key] = get(key)
    }
    return map
}

class InteractiveAction : ActionCallback {
  override suspend fun onAction(
    context: Context,
    glanceId: GlanceId,
    parameters: ActionParameters
  ) {
    val backgroundIntent =
      HomeWidgetBackgroundIntent.getBroadcast(
        context, Uri.parse("homeWidgetExample://titleClicked")
      )
    backgroundIntent.send()
  }
}