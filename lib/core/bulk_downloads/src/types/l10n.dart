class DownloadTranslations {
  const DownloadTranslations._();
  static const String title = 'sideMenu.bulk_download';
  static const String create = 'New download';
  static const String createShort = 'Create';
  static const String empty = 'No active download sessions';
  static const String delete = 'Delete';
  static const String copyPath = 'Copy path';
  static const String createdStatus = 'Created';
  static const String download = 'download.download';
  static const String addToQueue = 'Add to List';
  static const String allSkippedStatus = 'Completed with no new files';
  static String inProgressStatus(int? completed) =>
      'Scanning${completed != null ? ' page $completed ' : ''}...';
  static String titleInfoCounter(bool plural) =>
      plural ? '{} files' : '{} file';

  static const String saveToFolder = 'download.bulk_download_save_to_folder';
  static const String showAdvancedOptions = 'Show advanced options';
  static const String enableNotifications = 'Notifications';
  static const String selectFolder = 'settings.download.select_a_folder';

  static const String templates = 'Templates';
  static const String emptyTemplates = 'No templates';
  static const String createTemplate = 'Create a template';
  static const String templateCreated = 'Template created';
  static const String runTemplate = 'Run';
}
