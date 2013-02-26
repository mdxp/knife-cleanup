Knife-Cleanup
===

This is a [Knife](http://wiki.opscode.com/display/chef/Knife) plugin to help cleanup unused cookbook versions from a chef server. If you have an automated system that creates new cookbook versions for each commit (maybe something like [chef-jenkins](https://github.com/mdxp/chef-jenkins)) then your chef server might end up with thousands of cookbook versions and they most of them are unused. And this is perfectly fine... Still if this annoys you, this plugin will help you cleanup unused versions by looking into each environment and keeping the versions used there and also the latest version of each cookbook. Before deleting any cookbooks it will download and create a backup of them under `.cleanup/cookbook_name/`.

## <a name="installation"></a> Installation

You will need chef installed and a working knife config; development has been done on chef 11, but it should work with any version higher than 0.10.10

```bash
  gem install knife-cleanup
```

## <a name="usage"></a> Usage

For a list of commands:

```bash
  knife cleanup --help
```

Currently there is only one command available:

```bash
  knife cleanup versions <-D>
```

If you run it without --delete (-D) it will show you the versions that would be deleted. In delete mode it will save first a backup of the version and then proceed to delete it. I've seen various strange cases where knife is not able to download the cookbook version from the server, and be aware that we will skip those cases and there will not be a backup for that. You've been warned. 

Note: this is by no means production ready; I'm using it with success for my needs and hopefully you will find it useful too. Be sure to do a backup your chef server ([knife-backup](https://github.com/mdxp/knife-backup)) before using it, etc. 

## Todo/Ideas

  * Cleanup databags
  * Cleanup unused cookbooks

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Ideally create a topic branch for every separate change you make. For example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Marius Ducea][mdxp] (<marius.ducea@gmail.com>)

## <a name="license"></a> License

Apache License, Version 2.0 (see [LICENSE][license])
