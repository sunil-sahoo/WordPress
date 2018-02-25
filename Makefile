.PHONY: *

all: init 

build-base:
	docker build -t build-env -f Dockerfile.build .

init:
	chown -R www-data:www-data /project	
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar wp

reset:
	cp wp-config-sample.php wp-config.php
	sed -i 's/database_name_here/jigoshop/' wp-config.php
	sed -i 's/username_here/root/' wp-config.php
	sed -i 's/password_here/mariaSql/' wp-config.php
	sed -i 's/localhost/mariadb/' wp-config.php
	docker exec jigoshop sh -c './wp core install --url="http://$$(curl checkip.amazonaws.com)/" --title="Jigo Store" --admin_user="admin" --admin_password="admin123" --admin_email="email@domain.com" --skip-themes --allow-root'
	docker exec jigoshop chown -R www-data:www-data /var/www/html
	docker exec jigoshop sh -c './wp plugin install --activate jigoshop-ecommerce --allow-root'
	docker exec jigoshop sh -c './wp theme install --activate storefront --allow-root'
	docker exec jigoshop sh -c './wp plugin install --activate wordpress-importer --allow-root'
	docker exec jigoshop sh -c './wp import sample_products.xml --authors=create --allow-root --user=admin' 

up:
	docker-compose up -d

down:
	docker-compose down
