require 'nil/console'

class UserShell
  RegexpExamples =
    [
     ['abc', "matches #{Nil.white 'blahAbc'} and #{Nil.white 'ABC!'}"],
     ['first.*second', "equivalent to the 'wildcard' style notation #{Nil.white 'first*second'}, matches #{Nil.white 'xfirst123second'}"],
     ['release\.name', 'you will need to escape actual dots in scene release names since the dot is a special regexp symbol for "match any character"'],
     ['(a|b)', "matches all names containing an #{Nil.white 'a'} or a #{Nil.white 'b'}"],
     ['^blah', "matches all names starting with #{Nil.white 'blah'}, like #{Nil.white 'blahx'} but not #{Nil.white 'xblah'}"],
     ['blah$', "matches all names ending with #{Nil.white 'blah'}, like #{Nil.white 'xblah'} but not #{Nil.white 'blahx'}"],
    ]
end
