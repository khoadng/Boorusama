# 3.12.5
- Fix data loading issue on some sites
- Attempt to fix an issue where the app fails to start up on some devices

# 3.12.4
- Add translations for Thai and Norwegian Bokmål
- Add a way for users to report issues and contact the developer
- Fix an issue with importing/exporting bookmarks

# 3.12.3
- Add an error screen with information when the app fail to start up
- Fix an issue in shimmie2 where images are downloaded without an file extension
- Fix a bug that prevents grid's header from showing up in some sites
- Sharing image will now include the image's extension properly
- In paginated mode,refreshing the page will refresh the current page instead of going back to the first page

# 3.12.2
- Add a new profile option to show artist name in the image grid
- Included an option to adjust the image's aspect ratio for standard grid
- Expanded the range of values for posts per page selection.
- Bug fixes.

# 3.12.1
- Remove redundant phone permission
- Notification permission is now not required to download images
- Allow user to remove custom download location.
- Fix an issue where notifications stop showing after a while. Clear the app's data or reinstall the app are required.
- Fix performance issues when the user has a lot of blacklisted tags
- Minor bug fixes and UI adjustments

# 3.12.0
- Support Szurubooru
- Allow gestures and preview image's thumbnail button to be customized for each profile
- Add options to adjust the image grid padding and image viewer's UI overlay
- Improve the search page to make it more convenient to use
- Bug fixes and performance improvements

# 3.11.0
- Show original source for bookmarked posts and allow tapping on a tag to search for it
- Add a custom option for advance rating filtering
- Add a 'source' metatag for blacklisting posts with a specific source e.g. `source:*example.com* score:<0`
- [Moebooru] Allow logged-in users to favorite posts and view their favorites
- Improve the performance on certain sites
- Bug fixes and UI adjustments

# 3.10.1
- Add a toggle for changing page indicator postition
- Performance improvements and bug fixes

# 3.10.0
- Introduce swipe gesture for paginated mode.
- Enhance user experience for favorite tags with improved UI and additional options.
- Integrate Weblate for translation.
- Address issue where sound won't play on WebM files.
- Overall UI/UX improvements.

# 3.9.2
- Fix an issue where webm files cannot be played.
- Fix tag highlighting not working on some sites.

# 3.9.1
- Add an option to hide bookmarked posts from search results.
- Bug fixes and UI/UX improvements.

# 3.9.0
- Support exporting/importing booru profiles and settings.
- Centralize all export/import options into a new section in settings.
- Display more information in file details.
- Add an 'uploaderid' metatag to filter posts by uploader ID.
- Enable swipe-from-edge gesture to navigate back on most pages.
- Address several issues with the video player.

# 3.8.1
- Fix an issue where the download won't start in bookmark details.
- Add a button to display some statistics for the current query.
- Fix the crash issue on some devices using Android 8 and below.

# 3.8.0
- Migrate to Material 3, support dynamic theme color for Android 12+
- Show more information in bookmark details
- Add more privacy focus features like incognito keyboard, biometric lock
- Add an option to duplicate a profile
- Add an option to clear image cache on startup
- [Danbooru] Add a button to show a post version history
- [Gelbooru] Add a favorite tab
- A lot of bug fixes and UI adjustments

# 3.7.1
- Add a mute button for videos
- Add an option in profile settings to change default image resolution
- Minor bug fixes

# 3.7.0
- Introduce custom filename formatting for downloaded files, which you can find in profile settings.
- Improve bookmark management, you can now filter and sort bookmarks.
- Allow the import/export of bookmarks as a file.
- Make search suggestions more responsive.
- [Danbooru] Add artist search page.
- Performance improvements and bug fixes.

# 3.6.0
- Add tag highlighing for various sites
- [Danbooru] Add support tag editting
- Fix an issue where downloading a video would result in an image file for some sites.
- Performance improvement and bug fixes

# 3.5.3
- Add Data and Storage settings
- [Gelbooru V2] Add tag highlighting in post details
- Resolve an issue with certain sites not functioning on Android 7 and below
- Address several minor bug fixes

# 3.5.2
- Fix reordering profiles not working again
- Fix filter won't be applied properly
- Add a default new when creating a new profile
- Update Spanish translation

# 3.5.1
- Minor bug fixes

# 3.5.0
- Add support for Gelbooru V1, Sankaku, Philomena, Shimmie2
- Support export bookmarks as file (Will add import feature in the future)
- [Zerochan] Allow bulk download
- [Danbooru] Add basic Dmail support
- Add a button to move to search page from favorites page
- Fix bulk download not working on some devices
- Fix image failing to load on some sites
- Fix reordering profiles not working properly
- Various bug fixes and UI adjustments

# 3.4.1
- Fix an issue where some buttons are not tappable
- Fix a bug that causes images to not load properly when switching between tabs

# 3.4.0
- [Danbooru] Add Profile page
- [Moebooru] Show parent/child posts in post details
- Add an option to import/export blacklisted tags as text
- Add support for all Gelbooru v0.2 sites (hopefully)
- Add support for Zerochan
- Only auto-blacklists censored tags on Danbooru, not other Danbooru-based sites
- Fix an issue where video don't display duration on some sites

# 3.3.5
- Fix an issue from the previous update that causes some sites to not load properly
- Minor bug fixes

# 3.3.4
- Fix an error that causes a certain site to not load properly
- [Danbooru] Add censored tags to the default blacklist if the user doesn't have the privilege to view them.
- Minor bug fixes.

# 3.3.3
- Autoplay MP4 videos.
- Add a button to retry a failed/canceled download in bulk download page
- Introduce a `downvotes` metatag to the global blacklist for filtering posts with more than a specified number of downvotes (e.g. `downvotes:>5`).
- Enhance loading speed in specific scenarios.
- [Danbooru] Enable users to share any links and redirect them to the upload page.
- Resolve an issue causing the app to crash when consecutively opening multiple videos.

# 3.3.2
- Include some text to make configuring sites less confusing
- Reintroduce video handle for skipping forward and backward.
- Show download toast when a download starts

# 3.3.1
- Fix an issue where a certain site does not parse data correctly.
- [Danbooru] Show artists' URLs on the artist page.
- Minor UI adjustments.

# 3.3.0
- Groundwork for desktop version
- Move all items in the bottom navigation bar to the side drawer
- Update overall UI, UX for creating/editing/selecting sites
- Blacklisted tags are now can be turned on/off in image list
- Global blacklisted tags are now using Danbooru's blacklist syntax. Also support filter using rating and score
- [Danbooru] Add related tags and tag cloud 
- Minor bug fixes and UI adjustments

# 3.2.1
- Fix an issue that causes users to be unable to select a download folder if the app is installed in a different user space
- Minor updates to Chinese (Simplified) translation

# 3.2.0
- Initial forum support for Danbooru
- Add comment support for Gelbooru
- Revamp the details page for Moebooru to match the other sites
- Add a recently popular tab for Moebooru
- Streamline the booru site selection process
- Revamp the UI for tag list
- Fix an issue where changing the booru site won't register until the app is restarted
- Fix an bug where blacklisted tags are not properly applied
- Add Chinese (Traditional) translation and update Spanish translation
- Minor UI adjustments and bug fixes

# 3.1.0
- Add support for e621/e926
- Add some translations for Turkish and Ukrainian
- Add and update translations for French and Chinese (Simplified)

# 3.0.3
- Adjust the sensitivity of the swipe to dismiss gesture
- Fix an issue where you can't tap on the translation notes
- Add a highest quality option for choosing image quality
- Update translations for German and Portuguese (BR)
- Fix a few UI glitches

# 3.0.2
- Fix a bug where '-' and '~' search operators don't work
- Add a quick action context menu for adding tags to global blacklist in post details
- Add a page input field when using pagination
- Add translation for Portuguese (BR)
- A few minor UI adjustments and bug fixes

# 3.0.1
- Fix display issues on tablets
- Various bug fixes

# 3.0.0
- Support other boorus sites
- Redesign details page
- Improve performance when loading images
- Bulk download is now out of beta, no need to stay in the screen to keep the download going
- Add a translation project for the app

# 2.11.2
- Fixed broken thumbnails

# 2.11.1
- Fixed issue with bulk download permissions not being granted correctly
- Resolved issue with bulk downloads not showing any progress
- Temporarily disabled related tags in the search page 
- Fixed some network security issue

# 2.11.0
- Add a user details page
- Add a new settings for performance
- You can long press a tag to quickly add it to blacklist in post details
- Add a view comments button in context menu
- Add compatibility support for Android 13
- Use higher quality images for animated posts' thumbnails

# 2.10.0
- Add support for favorite groups
- Add a search bar in search history page
- Reduce memory usage when loading images
- Fix a bug where pick a previous item with multiple tags in history will be meshed into 1 tag
- Fix the API access denied issue

# 2.9.0
- Replace preview menu with context menu when long press an image  
- Add a mode where you can select multiple images at once to perform actions on them. You can find it in the context menu  
- Open search page will now auto focus the search bar. You can turn it off in search settings  
- Add a rotate button in full image view  
- Partially support Japanese language  
- Show more useful error messages
- Fix an issue where download failed to start when using experimental download method  
- Fix a bug that caused pages to be skipped when browsing character/artist posts  

# 2.8.4
- Remove Curated section
- Posts with Flash format are hidden because the app can't play Flash files at all
- Minor compatibility fixes with animated posts

# 2.8.3
- Images in pools are now sorted in decreasing order, which means newer images are showed first
- Slightly increase pool loading speed
- Tapping on favorites count now will show a list of users that favorites a post correctly
- Fix an issue where pool cover images cannot be showed
- Fix a bug where the app failed to search for any tag combination that has fewer than 60 items 

# 2.8.2
- Fix an issue where images failed to load

# 2.8.1
- Fix an issue where search history cannot be cleared
- Fix various internal errors

# 2.8.0
- Improve overall performance when loading images
- Persist date selector at bottom in explore page
- Support pagination for search page
- Make search bar in search page scrollable
- Prevent adding duplicate tag in search page
- Show total results when searching for images
- Add a new screen to manage history tags
- Minor UI adjustment
- Fix an issue where user can't move cursor in search bar
- Fix an issue where only 20 translation notes can be loaded

# 2.7.0
- Add saved search. 
- Revamp post details, show more information by default.
- Add a button to switch to a gallery mode that focus only on image.
- Add a quick favorite button in image list.
- Add a button to view post in browser
- Add favorite tags. Now you can save your frequently used tag at ease. Support import/export tag string as text.

# 2.6.1
- Fix a bug where a download will fail if copyright tags are not present.

# 2.6.0
- Introduce bulk download images (BETA).
- The app now use masonry layout to display images.
- Allow deleting individual history tags
- Add a button to open up quick action menu for selected tags in search page.
- Buttons in character/artist page will stay in place when the body is scrolling up
- Increase animation speed when swiping between posts
- Add a "Changelog" section in Settings.
- Remove grid preview in Settings because it's a pain to maintain :(
- Fix an issue where zooming the image will also zoom all the buttons
- Fix a bug where favoriting a post that has a parent will cause blank screen

# 2.5.2
- Fix a weird issue where opening up a keyboard on the search page will make things slower to load.
- Fix an issue on the detail page where swiping left and right will cause the pools text to disappear and reappear 
- Fix a bug that causes the search timeout to be very slow to appear
- Fix a bug on the detail page that will make the screen appear blank when tapping on one of the preview images.
- Make the favorite button and vote buttons more responsive to input.

# 2.5.1
- Fix a huge bug that prevents logged-out users to see anything
- Fix an issue where the quick filters on top of the home page and search page don't work
- Fix an issue with typing quickly and press submit in the search bar won't display the result properly
- Fix the circular scrolling bug in Explore/Most Viewed page
- Minor UI adjustment.
- Add Belarusian translation.

# 2.5.0
- Add post voting for logged in user
- Add a "Hot" section on Explore page
- Add an option to switch to an alternative download method
- Make metatags easier to access on the search page, also list today's most trending tags.
- Show more stuff on the detail page.
- Tap on vote count and favorite count to see who favorites/votes for that post. 
- Add Russian translation.

# 2.4.0
- Highlight search terms in suggestions
- Add a favorite button in the image context menu
- Fix an issue where suggested tags on the search page aren't displaying properly
- Minor UI adjustments

# 2.3.0
- Support landscape mode, recommend for tablet users
- Improve tag search speed
- Show past searches in the suggestion
- Minor UI, UX adjustment
- Bug fixes and optimization

# 2.2.0
- Add a quick action to add a tag to the blacklist
- Add an option to edit a blacklisted tag entry
- Whitespace is automatically converted to underscore in the search bar so you don't have to manually type it.
- Add a home button to make it easier to get back to the home screen
- Add an option in settings to use original quality as default when viewing the image in full view
- Fix an issue where the parent-child UI won't display properly