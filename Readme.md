cucumber-json
=============

A [Cucumber Output Formatter](http://wiki.github.com/aslakhellesoy/cucumber/custom-formatters)
that generates JSON.

    Feature: JSON formatter
      As a developer
      I want to receive reports of failing cucumber features in a parsable format
      In order to facilitace elegant continuous integration
      In order to protect revenue

Installation
------------

    gem install cucumber-json

Usage
-----

In your project:

    cucumber --format Cucumber::Formatter::JSON

Or, to output to a file:

    cucumber --format Cucumber::Formatter::JSON --out path/to/filename

Parsing
-------

The JSON generated is a hash that has 3 keys:

* failing_features
  * an array of all failing features, in a format similar to the default
    cucumber format
* features
  * an array of all  features, in a format similar to the default cucumber
    format
* status_counts
  * a hash of statuses, and the number of steps with that status
  
Additional information could be added to this hash in the future; this is just
what I needed at the moment.

Example
-------

The output of this project's cucumber features have been run through the
`Cucumber::Formatter::JSON` formatter and included at `examples/features.json`.
This was generated like so:

    cucumber -f Cucumber::Formatter::JSON --out examples/features.json

Author
------

[Jesse Newland](http://twitter.com/jnewland)

License
-------

MIT, same license as Ruby. See `LICENSE` for more details