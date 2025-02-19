class DownloadTranslations {
  const DownloadTranslations._();
  static const String title = 'Bulk Download';
  static const String create = 'New download';
  static const String empty = 'No active download sessions';
  static const String delete = 'Delete';
  static const String copyPath = 'Copy path';
  static const String createdStatus = 'Created';
  static const String download = 'Download';
  static const String addToQueue = 'Queue';
  static const String allSkippedStatus = 'Completed with no new files';
  static String inProgressStatus(int? completed) =>
      'Scanning${completed != null ? ' page $completed ' : ''}...';
  static String titleInfoCounter(bool plural) =>
      plural ? '{} files' : '{} file';

  static const String saveToFolder = 'download.bulk_download_save_to_folder';
  static const String showAdvancedOptions = 'Show advanced options';
  static const String enableNotifications = 'Notifications';
  static const String selectFolder = 'download.bulk_download_select_a_folder';

  static const String templates = 'Templates';
  static const String emptyTemplates = 'No templates';
  static const String createTemplate = 'Create a template';
  static const String templateCreated = 'Template created';
}
