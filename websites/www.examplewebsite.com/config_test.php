<html>
  <body>
  Hello World! <?php echo " and Hello PHP!"; ?><br/><br/>

  PHP Extensions:
  <?php
  print_r(get_loaded_extensions());
  ?>
  <br/><br/>

  DB Connection Test:
  <?php
    $servername = "db.examplewebsite.com";
    $username   = "ex_user";
    $password   = "ex_pw";

    // Create connection
    $conn = new mysqli($servername, $username, $password);

    // Check connection
    if ($conn->connect_error) {
      die("Connection failed: " . $conn->connect_error);
    }
    echo "Connected to db.examplewebsite.com successfully";
  ?>
  <br/><br/>

  Memcached Connection Test:
  <?php
    $m = new Memcached();
    $m->addServer('127.0.0.1', 11211);
    echo "Setting \$m->set('foo', 100);  \$m->get('foo') Result:";
    $m->set('foo', 100);
    var_dump($m->get('foo'));
  ?>

  </body>
</html>