#!/bin/bash

set -eo pipefail

echo "Executing MySQL Initialization Script..."

# Allow stack-io and root users to connect from anywhere
printf "[INFO] Granting privileges to stack-io and root users...\n"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    GRANT ALL PRIVILEGES ON *.* TO 'stack-io'@'%' WITH GRANT OPTION;

    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;

    FLUSH PRIVILEGES;

    FLUSH PRIVILEGES;

    DROP DATABASE IF EXISTS blog;
    CREATE DATABASE blog;
    USE blog;
EOSQL
 
if [ $? -eq 0 ]; then
    printf "[INFO] Privileges granted successfully.\n"
else
    printf "[ERROR] Failed to grant privileges.\n"
fi

# Create blog database and tables
printf "[INFO] Creating blog database and tables...\n"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    USE blog;

    CREATE TABLE IF NOT EXISTS users (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(30) NOT NULL,
        email VARCHAR(50) NOT NULL,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    
    CREATE TABLE IF NOT EXISTS posts (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        user_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    
    CREATE TABLE IF NOT EXISTS comments (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        content TEXT NOT NULL,
        user_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_posts (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        user_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_comments (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        content TEXT NOT NULL,
        user_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_tags (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_tags (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        post_id INT(6) UNSIGNED NOT NULL,
        tag_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES blog_tags(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_comments (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        content TEXT NOT NULL,
        user_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_likes (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_dislikes (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_views (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_reports (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        reason TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_comment_reports (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        comment_id INT(6) UNSIGNED NOT NULL,
        reason TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (comment_id) REFERENCES blog_post_comments(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_comment_likes (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        comment_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (comment_id) REFERENCES blog_post_comments(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_comment_dislikes (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        comment_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (comment_id) REFERENCES blog_post_comments(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_comment_replies (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        content TEXT NOT NULL,
        user_id INT(6) UNSIGNED NOT NULL,
        comment_id INT(6) UNSIGNED NOT NULL,
        reply_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (comment_id) REFERENCES blog_post_comments(id) ON DELETE CASCADE,
        FOREIGN KEY (reply_id) REFERENCES blog_post_comment_replies(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    CREATE TABLE IF NOT EXISTS blog_post_comment_reply_likes (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id INT(6) UNSIGNED NOT NULL,
        reply_id INT(6) UNSIGNED NOT NULL,
        comment_id INT(6) UNSIGNED NOT NULL,
        post_id INT(6) UNSIGNED NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (reply_id) REFERENCES blog_post_comment_replies(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (comment_id) REFERENCES blog_post_comments(id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES blog_posts(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOSQL

if [ $? -eq 0 ]; then
    printf "[INFO] Tables created successfully.\n"
else
    printf "[ERROR] Failed to create tables.\n"
fi

# Create Mock Data to play with
printf "[INFO] Creating mock data...\n"
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    USE blog;

    INSERT INTO users (name, email, password, created_at, updated_at) VALUES
    ('John Doe', 'johndoe@example.com', 'password', NOW(), NOW()),
    ('Jane Doe', 'janedoe@example.com', 'password', NOW(), NOW()),
    ('Bob Smith', 'bobsmith@example.com', 'password', NOW(), NOW());
    
    INSERT INTO blog_posts (title, content, user_id, created_at, updated_at) VALUES
    ('First Post', 'This is my first post', 1, NOW(), NOW()),
    ('Second Post', 'This is my second post', 2, NOW(), NOW()),
    ('Third Post', 'This is my third post', 3, NOW(), NOW());
    
    INSERT INTO blog_post_comments (content, user_id, post_id, created_at, updated_at) VALUES
    ('Great post!', 1, 1, NOW(), NOW()),
    ('Thanks for sharing', 2, 1, NOW(), NOW()),
    ('I disagree with your point of view', 3, 1, NOW(), NOW());
    
    INSERT INTO blog_post_likes (user_id, post_id, created_at, updated_at) VALUES
    (1, 1, NOW(), NOW()),
    (2, 1, NOW(), NOW()),
    (3, 1, NOW(), NOW());
    
    INSERT INTO blog_post_dislikes (user_id, post_id, created_at, updated_at) VALUES
    (1, 2, NOW(), NOW()),
    (2, 2, NOW(), NOW()),
    (3, 2, NOW(), NOW());
    
    INSERT INTO blog_post_views (user_id, post_id, created_at, updated_at) VALUES
    (1, 3, NOW(), NOW()),
    (2, 3, NOW(), NOW()),
    (3, 3, NOW(), NOW());
    
    INSERT INTO blog_post_reports (user_id, post_id, reason, created_at, updated_at) VALUES
    (1, 1, 'This post contains inappropriate content', NOW(), NOW()),
    (2, 2, 'This post is spam', NOW(), NOW()),
    (3, 3, 'This post violates community guidelines', NOW(), NOW());
    
    INSERT INTO blog_post_comment_reports (user_id, comment_id, reason, created_at, updated_at) VALUES
    (1, 1, 'This comment contains inappropriate content', NOW(), NOW()),
    (2, 2, 'This comment is spam', NOW(), NOW()),
    (3, 3, 'This comment violates community guidelines', NOW(), NOW());
    
    INSERT INTO blog_post_comment_likes (user_id, comment_id, created_at, updated_at) VALUES
    (1, 1, NOW(), NOW()),
    (2, 1, NOW(), NOW()),
    (3, 1, NOW(), NOW());
    
    INSERT INTO blog_post_comment_dislikes (user_id, comment_id, created_at, updated_at) VALUES
    (1, 2, NOW(), NOW()),
    (2, 2, NOW(), NOW()),
    (3, 2, NOW(), NOW());

    INSERT INTO blog_post_comment_replies (content, user_id, comment_id, reply_id, created_at, updated_at) VALUES
    ('Thanks for your comment!', 1, 1, 1, NOW(), NOW()),
    ('You are welcome!', 2, 1, 2, NOW(), NOW()),
    ('Why do you disagree?', 3, 1, 3, NOW(), NOW());

    INSERT INTO blog_post_comment_reply_likes (user_id, reply_id, comment_id, post_id, created_at, updated_at) VALUES
    (1, 1, 1, 1, NOW(), NOW()),
    (2, 2, 1, 1, NOW(), NOW()),
    (3, 3, 1, 1, NOW(), NOW());
EOSQL