@extra-timeout @creates-remote @disable-bundler
Feature: Kumade executable
  As a user
  I want to be able to use the kumade executable
  So I can have a better experience than Rake provides

  Background:
    Given a directory named "executable"
    And I cd to "executable"
    And I write to "Gemfile" with:
    """
      gem 'kumade', :path => '../../..'
      gem 'jammit'
    """
    And I run `bundle --gemfile=./Gemfile --local || bundle --gemfile=./Gemfile`
    When I successfully run `git init`
    And I successfully run `touch .gitkeep`
    And I successfully run `git add .`
    And I successfully run `git commit -am First`
    And I create a Heroku remote for "pretend-staging-app" named "pretend-staging"
    And I create a Heroku remote for "app-two" named "staging"
    And I create a non-Heroku remote named "bad-remote"

  Scenario: Pretend mode with a Heroku remote
    When I run `bundle exec kumade pretend-staging -p`
    Then the output should contain "In Pretend Mode"
    And the output should contain:
      """
      ==> Git repo is clean
      ==> Packaged assets with Jammit
               run  git push origin master
      ==> Pushed master -> origin
               run  git push -f pretend-staging deploy:master
      ==> Force pushed master -> pretend-staging
      ==> Migrated pretend-staging-app
               run  git checkout master && git branch -D deploy
      ==> Deployed to: pretend-staging
      """
    But the output should not contain "==> Packaged assets with More"

  Scenario: Default environment is staging
    When I run `bundle exec kumade -p`
    Then the output should contain "==> Deployed to: staging"

  Scenario: Can deploy to arbitrary environment
    When I run `bundle exec kumade bamboo`
    Then the output should contain "==> Deploying to: bamboo"
    Then the output should match /Cannot deploy: /

  Scenario: Deploying to a non-Heroku remote fails
    When I run `bundle exec kumade bad-remote`
    Then the output should match /==> ! Cannot deploy: "bad-remote" remote does not point to Heroku/

  Scenario: Deploy from another branch
    When I run `git checkout -b new_branch`
    When I run `bundle exec kumade pretend-staging -p`
    Then the output should contain:
      """
      ==> Git repo is clean
      ==> Packaged assets with Jammit
               run  git push origin new_branch
      ==> Pushed new_branch -> origin
               run  git push -f pretend-staging deploy:master
      ==> Force pushed new_branch -> pretend-staging
      ==> Migrated pretend-staging-app
               run  git checkout new_branch && git branch -D deploy
      ==> Deployed to: pretend-staging
      """
