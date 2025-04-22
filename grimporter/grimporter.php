<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GR 星标文章转换器</title>
    <link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen">
</head>
<body>
<div class="container">
<?php

$pagestartime = microtime(true);

// 数据库配置
$host = "YOURHOST";
$username = "YOURNAME";
$password = "YOURPSWD";
$database = "YOURDB";

// 创建数据库连接
$mysqli = new mysqli($host, $username, $password, $database);

// 检查连接是否成功
if ($mysqli->connect_error) {
    die("数据库连接失败: " . $mysqli->connect_error);
} else {
    echo "数据库连接成功！<br>";
}

// 处理上传的文件
$file_input = $_FILES["file"];
$file_name = $file_input["name"];
$file_tmp_dir = $file_input["tmp_name"];
$dir = __DIR__; // 使用 __DIR__ 获取当前目录
$now_stmp = time();
$new_name = $dir . "/upload/" . $now_stmp . "_" . $file_name;

// 检查文件类型
if ($file_input["type"] != "application/json") {
    echo "无效的 JSON 文件，请重试！";
    exit;
} else {
    // 上传文件
    $up_action = move_uploaded_file($file_tmp_dir, $new_name);
    if ($up_action) {
        echo "文件上传成功！";
        $filename = $new_name;
    } else {
        echo "文件上传失败！";
        exit;
    }
}

// 检查文件是否存在
if (file_exists($filename)) {
    echo "文件验证通过，继续执行！<br>";
} else {
    echo "无效的文件，请检查！<br>";
    exit;
}

// 开始读取文件
$content = json_decode(file_get_contents($filename), true);
if ($content === null && json_last_error() !== JSON_ERROR_NONE) {
    echo "JSON 文件解析失败: " . json_last_error_msg() . "<br>";
    exit;
}

$user = $content['author'];
// 创建表
$create_sql = "CREATE TABLE IF NOT EXISTS `" . $user . "` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `url` VARCHAR(255) NOT NULL
)";

if ($mysqli->query($create_sql) === TRUE) {
    echo "表 " . $user . " 创建成功或已存在。<br>";
} else {
    echo "创建表时出错: " . $mysqli->error . "<br>";
}

// 插入数据
foreach ($content['items'] as $item) {
    $feed_title = $item['title'];
    $alt = $item['alternate'];
    $href = $alt[0]['href'];

    // 使用预处理语句
    $inser_sql = "INSERT INTO `" . $user . "` (`title`, `url`) VALUES (?, ?)";
    $stmt = $mysqli->prepare($inser_sql);
    if ($stmt === false) {
        echo "预处理语句出错: " . $mysqli->error . "<br>";
        exit;
    }
    $stmt->bind_param("ss", $feed_title, $href);

    if ($stmt->execute()) {
        echo "<p><a href='" . htmlspecialchars($href) . "' target='_blank'>" . htmlspecialchars($feed_title) . "</a></p>";
    } else {
        echo "插入数据时出错: " . $stmt->error . "<br>";
    }

    $stmt->close();
}

$pageendtime = microtime(true);
$totaltime = $pageendtime - $pagestartime;
$timecost = sprintf("%.4f", $totaltime);
echo "耗时: " . $timecost . " 秒";

$mysqli->close();

?>
</div>
</body>
</html>
