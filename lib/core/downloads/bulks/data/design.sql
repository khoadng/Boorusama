/* 
- When the user opens the Create Task UI, they fill in task parameters (path, tags, download options) that get stored in the download_tasks table.
- For premium users, the UI also presents a "Download Later" option. If selected, the task is flagged for later execution.
- Once the task is created, if the user clicks “Start Download,” the app immediately creates a session in download_sessions and starts a dry run. It gathers metadata and produces download_records for items to download.
- In the bulk download UI, all tasks from download_tasks are listed. For premium users, tasks that are saved are also displayed, allowing them to quickly re-run the task with its preconfigured settings.
- When a task is started, a session is created
- The app will start a dry run and search using tags and go page by page to collect and decide what to download/skip
- If the app decides to download, it will create a record in download_records
- After dry run, the app will start downloading page by page
- When all records are completed, the session is marked as completed
- If a session is interrupted, the app will resume from the last page
*/

CREATE TABLE download_tasks (
    id TEXT PRIMARY KEY,
    path TEXT NOT NULL,
    notifications BOOLEAN NOT NULL DEFAULT 0,
    skip_if_exists BOOLEAN NOT NULL DEFAULT 1,
    quality TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    per_page INTEGER NOT NULL DEFAULT 100,
    concurrency INTEGER NOT NULL DEFAULT 5,
    tags TEXT
);

CREATE TABLE download_task_versions (
    id INTEGER PRIMARY KEY,
    task_id TEXT NOT NULL,
    version INTEGER NOT NULL,
    path TEXT NOT NULL,
    notifications BOOLEAN,
    skip_if_exists BOOLEAN,
    quality TEXT,
    per_page INTEGER,
    concurrency INTEGER,
    tags TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(task_id) REFERENCES download_tasks(id) ON DELETE CASCADE
);

CREATE TABLE saved_download_tasks (
    id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,
    active_version_id INTEGER, 
    name TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER,
    FOREIGN KEY(task_id) REFERENCES download_tasks(id) ON DELETE RESTRICT
);

CREATE TABLE download_sessions (
    id TEXT PRIMARY KEY,
    task_id TEXT,
    started_at INTEGER NOT NULL,
    completed_at INTEGER,
    current_page INTEGER NOT NULL DEFAULT 1,
    total_pages INTEGER,
    status TEXT NOT NULL,
    error TEXT,
    FOREIGN KEY(task_id) REFERENCES download_tasks(id) ON DELETE SET NULL
);

CREATE TABLE download_records (
    url TEXT NOT NULL,
    session_id TEXT NOT NULL,
    status TEXT NOT NULL,
    page INTEGER NOT NULL,
    page_index SMALLINT NOT NULL,
    created_at INTEGER NOT NULL,
    file_size INTEGER,
    file_name TEXT NOT NULL,
    extension TEXT,
    error TEXT,
    download_id TEXT,
    headers TEXT,           
    thumbnail_url TEXT,     
    source_url TEXT,        
    PRIMARY KEY(url, session_id),
    FOREIGN KEY(session_id) REFERENCES download_sessions(id) ON DELETE CASCADE
);

CREATE TABLE download_session_statistics (
    id INTEGER PRIMARY KEY,
    session_id TEXT UNIQUE,
    cover_url TEXT,         
    site_url TEXT,        
    total_files INTEGER,
    total_size BIGINT,
    average_duration INTEGER,  -- in milliseconds
    average_file_size BIGINT,
    largest_file_size BIGINT,
    smallest_file_size BIGINT,
    median_file_size BIGINT,
    avg_files_per_page REAL,
    max_files_per_page INTEGER,
    min_files_per_page INTEGER,
    extension_counts TEXT,     -- JSON object {".jpg": 100, ".png": 50, etc}
    FOREIGN KEY(session_id) REFERENCES download_sessions(id) ON DELETE SET NULL
);

CREATE INDEX idx_download_records_session_id ON download_records(session_id);
CREATE INDEX idx_download_sessions_task_id ON download_sessions(task_id);
CREATE INDEX idx_download_tasks_created_at ON download_tasks(created_at);
CREATE INDEX idx_download_records_status_session ON download_records(session_id, status);
CREATE INDEX idx_download_records_download_lookup ON download_records(session_id, download_id);
CREATE INDEX idx_download_sessions_status_started ON download_sessions(status, started_at);