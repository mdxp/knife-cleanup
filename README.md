Knife-Cleanup
===

This is a [Knife](http://wiki.opscode.com/display/chef/Knife) plugin to help cleanup unused cookbook versions from a chef server. If you have an automated system that creates new cookbook versions for each commit (maybe something like [chef-jenkins][chefjenkins]) then your chef server might end up with thousands of cookbook versions and they most of them are unused. And this is perfectly fine... Still if this annoys you, this plugin will help you cleanup unused versions by looking into each environment and keeping the versions used there and also the latest version of each cookbook. Before deleting any cookbooks it will download and create a backup of them under `.cleanup/cookbook_name/`.

## Installation

You will need chef installed and a working knife config; development has been done on chef 11, but it should work with any version higher than 0.10.10

```bash
gem install knife-cleanup
```

## Usage

For a list of commands:

```bash
knife cleanup --help
```

Options:

```bash
knife cleanup versions <-D|--delete> <-B|--backup> <-R|--runlist cookbook|role>
```

When run without the `-D` option, it will show you the versions that would be deleted, but not delete anything. The default mode only looks for cookbooks that are latest, or are explicitly pinned in an environment. With a `--runlist` option, it will obtain the cookbook versions associated with that run list in each environment. This is useful when, for example, your _default environment has java pinned at '< 1.16.0', and your unpinned environments are using java 1.15.5, and you happen to have a java 1.16.0 version in the server.

The delete mode will not make backup of the version unless you use the '-B|--backup' option.

With the backup option, I've seen various strange situations where knife is not able to download the cookbook version from the server, and be aware that we will skip those cases and there will not be a backup for such corrupted versions. You've been warned. 

Note: this is by no means production ready; I'm using it with success for my needs and hopefully you will find it useful too. Be sure to do a backup your chef server ([knife-backup][knifebackup] before using it, etc. 

## Todo/Ideas
  
  * Make backup location configurable
  * Cleanup databags
  * Cleanup unused cookbooks

## Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Ideally create a topic branch for every separate change you make. For example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

Created and maintained by [Marius Ducea][mdxp] (<marius.ducea@gmail.com>)

## License

Apache License, Version 2.0 (see [LICENSE][license])

[license]:      https://github.com/mdxp/knife-cleanup/blob/master/LICENSE
[mdxp]:         https://github.com/mdxp
[repo]:         https://github.com/mdxp/knife-cleanup
[issues]:       https://github.com/mdxp/knife-cleanup/issues
[knifebackup]:  https://github.com/mdxp/knife-backup
[chefjenkins]:  https://github.com/mdxp/chef-jenkins
