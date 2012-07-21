Trebek
======

Trebek is an elegant way to run surveys and questionnaires.

Do you want to write a survey in a simple plain text file and have an HTML form come out the other end? Trebek does that. Do you want to be able to take the content of your HTML form and process that? Trebek does that, too. Do you want to be able to see the results of your surveys? Trebek to the rescue again.

Installation
------------

```bash
git clone git://github.com/pyrmont/trebek.git  # Warning: read-only.
cd trebek
bundle install
bundle exec ruby trebek.rb # Kick it off in development mode
```

Now go and open [http://localhost:4567/]() in your browser and tell them Connery sent you.

Usage
------------

Trebek is designed to be flexible. We've included three example surveys in the `examples` folder so you can get an idea of how to write your surveys. Pretty straightforward right? If you've got Trebek running, go to [http://localhost:4567/examples/simple-names/]() to see it in action (or you can check out [http://localhost:4567/examples/complex/]() to see us showing off).

If you want to change the HTML that Trebek uses to display your survey, you can edit the templates that are in `views/tags`. No need to touch the actual application! There frame for the page is in `views` and stylesheets, JavaScript and images live in `public` naturally.

Licence
-------

Original code &copy; 2012 Michael Camilleri. Trebek is distributed under an [MIT Licence](http://en.wikipedia.org/wiki/MIT_License).