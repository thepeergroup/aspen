# Aspen

Aspen is a simple markup language that transforms simple narrative information into rich graph data for use in Neo4j.

To put it another way, Aspen is a simple language that compiles to Cypher, specifically for use in creating graph data.

Aspen transforms this:

`(Matt) [knows] (Brianna)`

into this:

`(Person {name: "Matt"})-[:KNOWS]->(Person {name: "Brianna"})`

(TODO insert graph image)

(It's only slightly more complicated than that.)

## Usage

Before reading this, make sure you know basic Cypher, to the point that you're comfortable writing statements that create and/or query multiple nodes and edges.


### Simplest Case

The simplest case for using Aspen is a simple relationship between two people.

> Matt knows Brianna.

If Matt knows Brianna, we can assume Brianna knows Matt as well.

You can safely guess that:

- "Matt" is a node (entity or object), "knows" is the relationship, and "Brianna" is another node
- "Matt" and "Brianna" are people, so they would have a Person label
- That the relationship is reciprocal

However, Aspen doesn't know any of this automatically! (At least not yet. Someday. Someday...)

So, we need to tell Aspen:

- Whether "Matt", "knows", and "Brianna" are nodes or edges
- What kind of labels to apply to the nodes
- That the relationship "knows" is implicitly reciprocal

To tell Aspen which parts are nodes and which are edges, we borrow the convention of using parentheses `()` to indicate nodes, and square brackets `[]` to indicate edges.

In Aspen, we write:

```
(Matt) [knows] (Brianna).
```

This isn't complete. If we ran this, we'd get the following:

```
I don't know what to do with these nodes: (Matt), (Brianna).

What kind of label should I apply to them, and what attribute should I assign the text to?

If these are people, and the text is their name, you can replace (Matt) and (Brianna) with (Person, name: Matt) and (Person, name: Brianna).

There's no default set, so if you write at the top of your file "default Person, name", you can keep the nodes the same and it'll assign "Matt" as the name of a Person node, and so forth.
```

So, let's write:

```
default Person, name

(Matt) [knows] (Brianna).
```

If we ran this, we'd get this Cypher:

```
(Person {name: "Matt"})-[:KNOWS]->(Person {name: "Brianna"})
```

However, we want the relationship "knows" to always be reciprocal.

In Cypher, we'd write "Matt knows Brianna" as:

```
(Person {name: "Matt"})-[:KNOWS]->(Person {name: "Brianna"})
(Person {name: "Matt"})<-[:KNOWS]-(Person {name: "Brianna"})
```

To get this reciprocality, we list all the reciprocal relationships after the keyword   `reciprocal`:

```
default Person, name
reciprocal knows

(Matt) [knows] (Brianna).
```

This gets us the Cypher we want!



### More complicated identifiers

Let's say we have this example.

```
default Person, name

(Matt) [knows] (Brianna)
(Matt Cloyd) [works at] (UMass Boston)
```

This isn't right yet either.

Notice a few things. First, we now have spaces in our identifiers: "Matt Cloyd", "works at", "UMass Boston". Also, UMass Boston isn't a person, it's an institution, organization, employer—whatever your schema, it will be something other than the default node of "Person". So we'll have to tell Aspen about this.

Aspen automatically converts relationships with spaces into the right syntax, so we can rest easy knowing `[works at]` will become `-[:WORKS_AT]->` in our Cypher. (At the moment, all relationships assign left-to-right.)

Let's first set up some protections to enforce a schema. This will tell Aspen to require us to use the right node labels.

```
protect
  nodes Person, Employer
  edges knows, works at

...
```

Now Aspen will catch us if we assign the wrong node or edge types.

Next, let's add the Employer node to UMass Boston.

```
default Person, name

...
(Matt) [works at] (Employer, name: "UMass Boston")
```

Here, the label is separated by a comma from its attributes. When we start writing attributes in this style, we have to swtich over to using quotes.

However, if we set a default attribute for the Employer node, we can make things a little cleaner.

```
default Person, name
default_attribute Employer, name

...

(Matt) [works at] (Employer, UMass Boston)
```

Let's go over the differences between `default` and `default_attribute`.

The `default` directive will catch any unlabeled nodes, like `(Matt)`, and label them. It will then assign the text inside the parentheses, `"Matt"`, to the attribute given as the default. If the default is `Person, name`, it will create a Person node with name "Matt".

The `default_attribute` will assign the inner text to the given attribute if it's a node of a specific type. For example,

```
default_attribute Employer, name
```


The whole code all together is:

```
default Person, name
default_attribute Employer, name

reciprocal knows

(Matt) [knows] (Brianna)
(Matt) [works at] (Employer, UMass Boston)
```

The Cypher produced generates the reciprocal "knows" relationship, and the one-way employment relationship.


```
MERGE (person-matt:Person { name: "Matt" } )
, (person-brianna:Person { name: "Brianna" } )
, (employer-umass-boston:Employer { name: "UMass Boston" } )

, (person-matt)-[:KNOWS]->(person-brianna)
, (person-matt)<-[:KNOWS]-(person-brianna)
, (person-matt)-[:WORKS_AT]->(employer-umass-boston)
```



If you want to assign both a first name and a last name to a Person node.

```
default map |fname, lname|
  Person({ first_name: fname, last_name: lname })
end

default Person, first_name

(Matt Cloyd) [knows] (Brianna)
```

### Attribute Uniqueness

```
default map |fname, lname|
  assign fname, first_name
  assign lname, last_name
end

default Person, first_name

(Matt Cloyd) [knows] (Matt)
```

```
You have a node named "Matt Cloyd" and a node named "Matt"?
Are these the same node, or different nodes? How can I know?
```

### Spaces in relationship names

### Reciprocal Relationships

```
reciprocal:
```

## Background

### Problem Statement

@beechnut, the lead developer of Aspen, attempted to model a simple conflict scenario in Neo4j's language Cypher, but found it took significantly longer than expected. He ran into numerous errors because it wasn't obvious how to construct nodes and edges through simple statements (TODO: Is this even possible).

We assume that most graph data is constructed through various forms and events in web applications. We assume that if the tools existed to support it, easy conversions of narrative statements into graph data would find wide use in a variety of fields.

It is a given that writing Cypher directly is time-consuming and error-prone, especially for beginners. This is not a criticism of Cypher—we love Cypher and think it's extremely-well designed. It is an observation that there's a gap between writing narrative statements and modeling relationships in Cypher. Aspen is attempting to bridge that gap.

### Hypotheses

We believe that graph databases and graph algorithms can provide deep insights into complex systems, and that people would find value in converting simple narrative descriptions into graph data is a worthwhile.

However, we don't know for sure that, if we were to provide this tool, that there would be significant use cases. People are creating graph data in other ways, and it's not clear that there's a need for this narrative-to-graph conversion.

## Contributing

Our dream for Aspen is that it would be able to allow custom grammars defined like Cucumber-tests, where narrative statements could be mapped to custom relationship structures. At the moment, Aspen is nowhere near this level of implicitness or complexity, and it would take a significant team working for a significant amount of time on this.

If you'd like to see Aspen grow, please get in touch, whether you're a developer, user, or potential sponsor. We have ideas on ways to grow Aspen, and we need your help to do so, whatever form that help takes. We'd love to invite a corporate sponsor to help inform and sustain Aspen's growth and development.

## Roadmap

```
[ ] Compile Aspen to Cypher.
  [ ] The simplest Aspen, with default, default_attribute, and reciprocal.
  [ ] Attribute uniqueness
  [ ] Custom attribute handling functions
  [ ] Schema and attribute protections
    [ ] Use dry-rb validations or schema to enforce Neo4j/Cypher requirements on tokens, like, must labels be one word capitalized?
  [ ] Implicit relationships
    [ ] Left-to-right
    [ ] Right-to-left
[ ] Live connection between an Aspen web application "Aspen Notebook" and Neo4j graph database instance.
[ ] Use Aspen Notebook to see diffs and publish data in a Neo4j instance.
[ ] Convert Neo4j data to Aspen.
```

### Features

__Attribute uniqueness__

Let's say you reference a person by first and last name, and later refer to that person by last name. Aspen will catch this and ask you to give enough unique attributes to confidently distinguish between the nodes. The only thing worse than messy narrative data is messy graph data.

__Handling spaces in identifiers (Custom attribute handling functions)__

Sometimes you'll want the default attribute on a node to be different, depending on how many attributes are given.

__Schema protections__

To protect against writing the wrong nodes and edges, we can add a `protect` block to allow only certain types of nodes and edges.

```
allow
  nodes Person
  edges knows, works at

# Throws an error because Friend is not an allowed node type.
(Friend, Matt) [knows] (Person, Brianna)

# Throws an error because "loves" is not an allowed relationship type.
(Person, Matt) [loves] (Person, Brianna)
```

To require that any  attributes
require
  Person: first_name
  works at: start_date


__Reciprocal relationships__

Some relationships are reciprocal—with few exceptions, if two people are friends, it's a two-way relationship.

```
...
reciprocal is friends with
(Matt) [is friends with] (Brianna)
```

Sometimes, we need to mention exceptions, like if someone thinks they're friends with someone else, but the other person doesn't.

```
...
reciprocal is friends with

(Matt) [is friends with | not reciprocal] (Brianna)
# or
(Matt) [is friends with | f] (Brianna)
```

We provide two ways to write it, one "not reciprocal" to be extra clear, or "f" for "false", which is shorter to write.

__Implicit relationships__

Some relationships naturally imply other relationships. For example, if two people are friends, they must know each other. In this particular case, it might be better for the querier to know that IS_FRIENDS_WITH and KNOWS are synonymous, avoiding data duplication, but whatever, this is a tutorial.

```
implicit
  is friends with -> knows

(Matt) [is friends with] (Brianna)
```

When this is compiled, it will assign the [:KNOWS] relationship before the [:IS_FRIENDS_WITH] relationships. All implicit relationships are run before. I don't know if this matters.

__Relationships that assign right-to-left__

Sometimes, we want to assign relationships right-to-left, `<-[:REL]-`, especially when running implicit relationships.

```
# TODO
```

__Mapping sentences to graphs__

```
map
  (Person p) donated $(Amount a) to (Person c).
  (Person p) gave (Person c) $(Amount a).
to
  (p)-[:GAVE_DONATION]->(Donation, amount: a)-[:TO]->(c)

# Aspen
(Matt) donated $(20) to (Hélène Vincent). # Can the parens be implicit?
Krista gave Hélène Vincent $30.

# Cypher
(Person {name: "Matt"})-[:GAVE_DONATION]->(Donation {amount: 20})-[:TO]->(Person {name: "Hélène Vincent."})
(Person {name: "Krista"})-[:GAVE_DONATION]->(Donation {amount: 30})-[:TO]->(Person {name: "Hélène Vincent."})
```



## Code of Conduct

There's an expectation that people working on this project will be good and kind to each other. The subject matter here is relationships, and anyone who works on this project is expected to have a baseline of healthy relating skills.

The full Code of Conduct is available at CODE_OF_CONDUCT.md.


----

# Aspen

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/aspen`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aspen'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install aspen

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aspen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/aspen/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Aspen project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/aspen/blob/master/CODE_OF_CONDUCT.md).
