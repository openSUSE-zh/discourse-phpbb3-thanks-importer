discourse-phpbb3-thanks-importer

------

Import phpbb 3.0 'thanks' mod to discourse likes.

It is a trival work, I don't even know if discourse reacts to direct postgresql database modification, 
and this is the 1st time I write rubygem to modify database. Let us have some fun!

## Usage ##

	cp -r config/config.yml.example config/config.yml

Fill your credentials, then

        bin/phpbb3-thanks-extractor

It will extract the thanks data from phpbb3's mysql database

Now map the ids to the ids in discourse's database

        bin/discourse-map-ids

Now push to discourse's Postgresql database:

	bin/discourse-thanks-importer
