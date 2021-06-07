<!-- ---
to: html
title: Starting a Python Project 
author: Faisal Z. Qureshi   
email: faisal.qureshi@ontariotechu.ca
date: May 19, 2021
institution: Ontario Tech University
subtitle: Setting up GIT for iPython Notebooks
institute: Ontario Tech University
sansfont: Gill Sans
titlegraphic: ontario-tech-univ-logo.png
web: http://faculty.uoit.ca/qureshi
page-numbers: True
geometry: margin=2cm
highlight: kate
css: "notes-style.css"
template: "notes-template.html"

--- -->
# Starting a Python project

This document lists steps that I follow when starting a new Python project.

# Steps

## Step 1: Create a git repo.  

I typically do it either on github or bitbucket.

## Step 2: Clone this empty git repo on to your local machine.

Voila.  Now you have an empty folder (with git setup) on your local machine.

## Step 3: Ensure that [nbstripout](https://pypi.org/project/nbstripout/) is installed.

This is a must if you plan to work with Jupyter Notebooks.  

~~~bash
$ sudo apt-get update
$ sudo apt-get -y install python3-pip
$ pip3 install nbstripout
$ nbstripout install
~~~

The `.git/config` will look something like this once the `nbstripout` is successfully setup for this repo.

~~~txt
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = git@github.com:vclab/axiom-analytics.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
	remote = origin
	merge = refs/heads/main
[filter "nbstripout"]
	clean = \"/usr/bin/python3\" -m nbstripout
	smudge = cat
[diff "ipynb"]
	textconv = \"/usr/bin/python3\" -m nbstripout -t
~~~

### Can't find `nbstripout` even after installation

If you can't seem to find `nbstripout` even after you have installed it, check out `~/.local/bin`.

~~~bash
$ ~/.local/bin/nbstripout install
~~~

## Step 4: Start coding.

Check out [here](python-dev.html) for some ideas on how to do Python development using Docker on remote machines.

*Happy hacking!*
