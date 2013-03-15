<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title></title>
    </head>
    <body>
<?php
/*
*需要首先设置一下mysql连接
*
*/
//设置mysql
$link =  mysql_connect("YOURHOST","YOURNAME","YOURPSWD");
mysql_select_db("YOURDB",$link);

$pagestartime=microtime(); 

//处理一下上传的文件
$file_input = $_FILES["file"];
$file_name = $file_input["name"];
$file_tem_dir = $file_input["tmp_name"];
$dir = dirname(__FILE__);
$now_stmp = time(now);
$new_name = "".$dir."/upload/".$now_stmp."".$file_name."";

if($file_input["type"] != "application/json"){
    echo "Invalid json file.Please retry!";
    exit;
}else{
    $up_action = move_uploaded_file($file_tem_dir,$new_name);
    if($up_action){
        echo "Upload success!";
        $filename = $new_name;
    }  else {
        echo "Upload failed!";
        exit;
    }
}

//判断文件是否存在
if(file_exists($filename)){
    echo "The file is right.Go on!";
    echo "<br>";
}  else {
    echo "Invalid file.Please check!";
    echo "<br>";
    exit;
}

//判断数据库连接是否正确
if($link){
    echo "DB link OK.Go on!";
    echo "<br>";
}  else {
    echo "DB link failed.Please check!";
    echo "<br>";
    exit;
}

//开始读取文件
$content = json_decode(file_get_contents($filename),TRUE);
$user = $content['author'];
$create_sql = "CREATE TABLE ".$user."
(
id int,
title varchar(100),
url varchar(100)
)";
mysql_query($create_sql,$link);

foreach($content['items'] as $item){
    $feed_title = $item['title'];
    $alt = $item['alternate'];
    $href = $alt['0']['href'];
    $inser_sql = "INSERT INTO ".$user."(title,url)VALUES('$feed_title','$href')";
    mysql_query($inser_sql,$link);
    echo "<p><a href='".$href."' target='_blank'>".$feed_title."</a></p>";
}

$pageendtime = microtime(); 
$starttime = explode(" ",$pagestartime); 
$endtime = explode(" ",$pageendtime); 
$totaltime = $endtime[0]-$starttime[0]+$endtime[1]-$starttime[1]; 
$timecost = sprintf("%s",$totaltime); 
echo "Time Used: $timecost S"; 

?>
    </body>
</html>
