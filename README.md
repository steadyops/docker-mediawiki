# Mediawiki Docker Image
Docker image for Mediawiki based on php:7.1.11-fpm-alpine3.4
This images comes preconfigured with Nginx, Parsoid and Visual Editor.

Parsoid is a prerequisite for Visual Editor, it runs locally on port 8000

If you want to know how this image was created checkout the full guide [mediawiki docker visual editor](https://www.steadyops.com/blog/mediawiki-visual-editor-docker-image)

# How to use
```bash
docker run --name mywiki -d -p 8080:80 steadyops/docker-mediawiki
```
Now open your browser and navigate to http://localhost:8080/ and follow the installation steps, don't forget to enable the visual editor extension in the process.
After you download LocalSettings.php file, copy it's contents then open your  container using this command

```bash
docker exec -it $(docker ps -qf name=mywiki) vi /var/www/html/LocalSettings.php
```
paste the contents then add the below lines then save

```php
if ( $_SERVER['REMOTE_ADDR'] == '127.0.0.1' ) {
 $wgGroupPermissions['*']['read'] = true;
 $wgGroupPermissions['*']['edit'] = true;
}
 $wgDefaultUserOptions['visualeditor-enable'] = 1;
```

# Notes
a special directory has been created with read/write access to place your database file if you chose Sqlite, just fill in the following path when asked for it `/var/www/data`

# To do
- [ ] Add docker-compose example in documentation
- [ ] Add link to MariaDB container
- [ ] Support upload persistence
