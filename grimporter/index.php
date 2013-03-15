<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen">
        <script src="http://code.jquery.com/jquery.js"></script>
        <script src="./bootstrap/bootstrap.min.js"></script>
        <title>GR星标文章转换器</title>
    </head>
    <body>
        <div class="container">
        <form class="form-inline" action="grimporter.php" method="post" enctype="multipart/form-data">
            <label for="file">Chose your file:</label>
            <input type="file" name="file" id="file" class="input-large" />
            <button type="submit" class="btn btn-primary">Upload</button>
        </form>
        </div>
    </body>
</html>
