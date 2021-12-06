# Aspen

Aspen is a simple markup language that transforms simple narrative information into rich graph data for use in Neo4j.

To put it another way, Aspen transforms narrative text to Cypher, specifically for use in creating graph data.

In short, Aspen transforms this:

```aspen
(Liz) [knows] (Jack)
```

into (roughly) this

```cypher
MERGE (:Entity { name: "Liz" })-[:KNOWS]->(:Entity { name: "Jack" })
```

and can push it to a Neo4j database.

Want Liz and Jack to be nodes with a `:Person` label? Just add a little config.

```aspen
default:
  label: Person
----
(Liz) [knows] (Jack)
```

```aspen
MERGE (:Person { name: "Liz" })-[:KNOWS]->(:Person { name: "Jack" })
```


### Installation

```
$ gem install aspen-cli
```

Start a new project:

```
$ aspen new your_project_name_here
```

### Documentation

[Quickstart Guide](https://github.com/thepeergroup/aspen/wiki/Quickstart-Guide)

[Full documentation in the Wiki](https://github.com/thepeergroup/aspen/wiki)


### Why use Aspen?

You need to turn notes and narratives into a network diagram or graph data.

You may also want to connect that data to other data, maybe graph data, maybe tabular data.

For what you want:

- Spreadsheets are too rigid,
- Machine learning and Natural Language Processing (NLP) are out of reach, and
- You're ok using command-line tools for now (we hope to offer a GUI soon)


## Code of Conduct

We expect that anyone working on this project will be good and kind to each other. We're developing software about relationships, and anyone who works on this project is expected to have healthy relating skills.

Everyone interacting in the Aspen project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/beechnut/aspen/blob/master/CODE_OF_CONDUCT.md).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beechnut/aspen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/beechnut/aspen/blob/master/CODE_OF_CONDUCT.md).

If you'd like to see Aspen grow, please [get in touch](https://github.com/thepeergroup/aspen/discussions), whether you're a developer, user, or potential sponsor. We have ideas on ways to grow Aspen, and we need your help to do so, whatever form that help takes.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

