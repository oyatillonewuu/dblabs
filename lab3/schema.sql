CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE CHECK (birth_date < "2026-02-12"), -- MySQL does not allow using functions like NOW
    country_code VARCHAR(2),
    subscription_type VARCHAR(20),
    registration_date TIMESTAMP,
    last_login DATETIME,
    PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS artists (
    artist_id INT AUTO_INCREMENT,
    artist_name VARCHAR(100) NOT NULL,
    biography TEXT,
    formed_year INT CHECK (formed_year >= 1900),
    country VARCHAR(50),
    is_verified BOOLEAN, -- Eqv: TINYINT(1)
    PRIMARY KEY (artist_id)
);

CREATE TABLE IF NOT EXISTS albums (
    album_id INT AUTO_INCREMENT,
    album_title VARCHAR(200) NOT NULL,
    artist_id INT,
    release_date DATE,
    genre VARCHAR(50),
    total_tracks INT CHECK (total_tracks >= 0), -- No way! Was not specified in the task, however.
    duration_minutes DECIMAL(5, 2) CHECK (duration_minutes > 0),

    PRIMARY KEY (album_id),
    FOREIGN KEY (artist_id)
        REFERENCES artists(artist_id)
);

CREATE TABLE IF NOT EXISTS songs (
    song_id INT AUTO_INCREMENT,
    song_title VARCHAR(200) NOT NULL,
    album_id INT,
    track_number INT,
    duration_seconds INT NOT NULL CHECK (duration_seconds > 0), -- Not specified,
                                                                -- but negative/zero duration is meaningless.
    explicit BOOLEAN,
    play_count BIGINT CHECK (play_count >= 0),
    release_date DATE,

    PRIMARY KEY (song_id),
    FOREIGN KEY (album_id)
        REFERENCES albums(album_id)
);

CREATE TABLE IF NOT EXISTS playlists (
    playlist_id INT AUTO_INCREMENT,
    user_id INT,
    playlist_name VARCHAR(100) NOT NULL,
    is_public BOOLEAN,
    created_date TIMESTAMP,
    description TEXT,

    PRIMARY KEY (playlist_id, user_id),
    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS playlist_songs (
    playlist_id INT,
    user_id INT,
    song_id INT,
    added_date TIMESTAMP,
    position INT,

    PRIMARY KEY (playlist_id, user_id, song_id),
    FOREIGN KEY (playlist_id, user_id)
        REFERENCES playlists(playlist_id, user_id),
    FOREIGN KEY (song_id)
        REFERENCES songs(song_id)
);
