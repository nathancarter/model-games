
This file defines some models and corresponding games you can
play on them.  It is included in the index file in this
directory, as an example of how to use `model-games.litcoffee`.

First, a game on the set of words made of Roman letters a-z.

    Words = new Model( 'Words',
        'words made from letters in the Roman alphabet, a to z',
        ( x ) -> /^[a-z]+$/.test x )
    Begins = Words.addOperator(
        ( ( a, b ) -> "begins(#{a},#{b})" ),
        ( ( a, b ) ->
            b.length is 1 and a.charAt( 0 ) is b.charAt( 0 ) ),
        null,
        "the word \\(x\\) begins with the letter \\(y\\)" )
    Ends = Words.addOperator(
        ( ( a, b ) -> "ends(#{a},#{b})" ),
        ( ( a, b ) ->
            b.length is 1 and \
            a.charAt( a.length - 1 ) is b.charAt( 0 ) ),
        null,
        "the word \\(x\\) ends with the letter \\(y\\)" )
    One = Words.addOperator(
        ( ( a ) -> "one(#{a})" ),
        ( ( a ) -> a.length is 1 ),
        null, "\\(x\\) is a one-letter word" )
    WordJ = Words.addConstant( 'J', 'J', 'job' )
    WordA = Words.addConstant( 'A', 'A', 'a' )
    Words.addGame Forall 'x', Begins WordJ, 'x'
    Words.addGame Exists 'x', Begins WordJ, 'x'
    Words.addGame Forall 'x', Ends 'x', WordA
    Words.addGame Exists 'x', Ends 'x', WordA
    Words.addGame Forall 'x', Forall 'y', \
        And Begins( WordJ, 'x' ), Ends( WordJ, 'y' )
    Words.addGame Exists 'x', Exists 'y', \
        And Begins( WordJ, 'x' ), Ends( WordJ, 'y' )
    Words.addGame Forall 'x', Exists 'y', Ends 'x', 'y'
    Words.addGame Exists 'x', Forall 'y', Ends 'x', 'y'
    Words.addGame Forall 'x', Forall 'y', Exists 'z', \
        And Begins( 'z', 'x' ), Ends( 'z', 'y' )
    Words.addGame Forall 'x', Forall 'y', Exists 'z', \
        Implies And( One( 'x' ), One( 'y' ) ), \
                And( Begins( 'z', 'x' ), Ends( 'z', 'y' ) )

Next, a game on the set of natural numbers with just the
less-than operation and a few small constants.

    Naturals = new Model( 'The natural numbers',
        'all natural numbers: 0, 1, 2, 3, etc...',
        ( x ) -> /^[0-9]+$/.test x )
    Less = Naturals.addOperator(
        ( ( a, b ) -> "#{a} < #{b}" ),
        ( ( a, b ) -> parseInt( a ) < parseInt( b ) ),
        null, "\\(x\\) is less than \\(y\\)" )
    NatEq = Naturals.addOperator(
        ( ( a, b ) -> "#{a} = #{b}" ),
        ( ( a, b ) -> parseInt( a ) is parseInt( b ) ),
        null, "ordinary equality of natural numbers" )
    Naturals.addGame Less 0, 1
    Naturals.addGame Less 2, 0
    Naturals.addGame Forall 'x', Exists 'y', Less 'x', 'y'
    Naturals.addGame Forall 'x', \
        Or NatEq( 'x', 0 ), Less( 0, 'x' )
    Naturals.addGame Exists 'x', Exists 'y', \
        And Less( 'x', 'y' ), Less( 'y', 1 )
    Naturals.addGame Exists 'x', Forall 'y', \
        And NatEq( 'x', 2 ), Less( 'x', 'y' )
    Naturals.addGame Exists 'x', Forall 'y', \
        And NatEq( 'x', 2 ), Less( 'x', 'y' )

Next, a game on the set of real numbers with ordinary operations
of arithmetic.

    Reals = new Model( 'The real numbers',
        'all real numbers, with simple algebraic operations',
        ( x ) -> /^[+-]?([0-9]+\.?|[0-9]*\.[0-9]+)$/.test x )
    Plus = Reals.addOperator(
        ( ( a, b ) -> "#{a} + #{b}" ),
        ( ( a, b ) -> parseFloat( a ) + parseFloat( b ) ),
        5, "ordinary addition" )
    Minus = Reals.addOperator(
        ( ( a, b ) -> "#{a} - #{b}" ),
        ( ( a, b ) -> parseFloat( a ) - parseFloat( b ) ),
        5, "ordinary subtraction" )
    Times = Reals.addOperator(
        ( ( a, b ) -> "#{a} \\times #{b}" ),
        ( ( a, b ) -> parseFloat( a ) * parseFloat( b ) ),
        10, "ordinary multiplication" )
    Div = Reals.addOperator(
        ( ( a, b ) -> "\\frac{#{a}}{#{b}}" ),
        ( ( a, b ) -> parseFloat( a ) / parseFloat( b ) ),
        10, "ordinary division" )
    GT = Reals.addOperator(
        ( ( a, b ) -> "#{a} > #{b}" ),
        ( ( a, b ) -> parseFloat( a ) > parseFloat( b ) ),
        1, "\\(x\\) is greater than \\(y\\)" )
    LT = Reals.addOperator(
        ( ( a, b ) -> "#{a} < #{b}" ),
        ( ( a, b ) -> parseFloat( a ) > parseFloat( b ) ),
        1, "\\(x\\) is less than \\(y\\)" )
    REQ = Reals.addOperator(
        ( ( a, b ) -> "#{a} = #{b}" ),
        ( ( a, b ) -> parseFloat( a ) is parseFloat( b ) ),
        1, "ordinary equality of real numbers" )
    Pi = Reals.addConstant( 'pi', '\\pi', Math.PI )
    Reals.addGame LT 0, 1
    Reals.addGame Exists 'x', LT 0, Times 'x', 'x'
    Reals.addGame Forall 'x', LT 'x', Plus 'x', 'x'
    Reals.addGame Exists 'x', Forall 'y', \
        REQ Plus( 'x', 'x' ), 1
    Reals.addGame Forall 'x', Exists 'y', \
        REQ Times( 'x', 'y' ), 1
    Reals.addGame Forall 'x', Exists 'y', \
        REQ Plus( 'x', 'y' ), 0
    Reals.addGame Forall 'x', Forall 'y', Exists 'w', \
        REQ Times( 'x', 'y' ), 'w'
    Reals.addGame Forall 'x', Forall 'y', Exists 'w', \
        REQ 'x', Times 'y', 'w'
    Reals.addGame Forall 'x', Forall 'y', Exists 'w', \
        Implies Not( REQ 'x', 0 ), \
                REQ Plus( Times( 'x', 'w' ), 'y' ), 0

Next, a game on the set of real numbers with predicates that
give hints of calculus.

    CReals = new Model( 'The real numbers',
        'all real numbers, with ideas related to calculus',
        ( x ) -> /^[+-]?([0-9]+\.?|[0-9]*\.[0-9]+)$/.test x )
    Times = CReals.addOperator(
        ( ( a, b ) -> "#{a} \\times #{b}" ),
        ( ( a, b ) -> parseFloat( a ) * parseFloat( b ) ),
        10, "ordinary multiplication" )
    LT = CReals.addOperator(
        ( ( a, b ) -> "#{a} < #{b}" ),
        ( ( a, b ) -> parseFloat( a ) > parseFloat( b ) ),
        1, "\\(x\\) is less than \\(y\\)" )
    REQ = CReals.addOperator(
        ( ( a, b ) -> "#{a} = #{b}" ),
        ( ( a, b ) -> parseFloat( a ) is parseFloat( b ) ),
        1, "ordinary equality of real numbers" )
    Close = CReals.addOperator(
        ( ( a, b, d ) -> "close(#{a},#{b},#{d})" ),
        ( ( a, b, d ) ->
            a = parseFloat a
            b = parseFloat b
            d = parseFloat d
            Math.abs( a - b ) < d ),
        null, "the distance on the number line between
            \\(x\\) and \\(y\\) is less than \\(z\\)" )
    CReals.addGame Forall 'x', Exists 'y', Close 'x', 'y', 2
    CReals.addGame Forall 'x', Exists 'y', \
        And Not( REQ 'x', 'y' ), Close 'x', 'y', 2
    CReals.addGame Exists 'x', Exists 'y', \
        And Not( REQ 'x', 'y' ), \
            REQ Times( 'x', 'x' ), Times( 'y', 'y' )
    CReals.addGame Exists 'x', Close -1, Times( 'x', 'x' ), 1
    CReals.addGame Forall 'x', Close 1, Times( 'x', 'x' ), 2
    CReals.addGame Forall 'e', Exists 'd', Forall 'x', \
        Implies LT( 0, 'e' ), And LT( 0, 'd' ), \
            Implies Close( 'x', 0, 'd' ), \
                    Close( Times( 'x', 'x' ), 0, 'e' )

Last, a game on a set of five friends with a relation shown by
a graph.

    Friends = new Model( 'A group of friends',
        'five friends, and who considers whom to be a friend',
        ( x ) -> x in [ 'Augustus', 'Beatriz', 'Cyrano', \
                        'Dauphine', 'Englebert' ] )
    Male = Friends.addOperator(
        ( ( a ) -> "male(#{a})" ),
        ( ( a ) -> a in [ 'Augustus', 'Cyrano', 'Englebert' ] ),
        null, "\\(x\\) is male (one of Augustus, Cyrano, or
         Englebert" )
    Female = Friends.addOperator(
        ( ( a ) -> "female(#{a})" ),
        ( ( a ) -> a in [ 'Beatriz', 'Dauphine' ] ),
        null, "\\(x\\) is female (one of Beatriz or Dauphine)" )
    Caf = Friends.addOperator(
        ( ( a, b ) -> "caf(#{a},#{b})" ),
        ( ( a, b ) -> {
            Augustus : Cyrano : 0
            Beatriz : Cyrano : 0
            Cyrano :
                Beatriz : 0
                Englebert : 0
            Dauphine : Cyrano : 0
            Englebert :
                Augustus : 0
                Beatriz : 0
        }[a].hasOwnProperty b ),
        null, "\\(x\\) considers \\(y\\) a friend, as shown in
        the graph<br><img src='graph.png'>" )
    Equal = Friends.addOperator(
        ( ( a, b ) -> "#{a} = #{b}" ),
        ( ( a, b ) -> a is b ),
        null, "\\(x\\) is equal to \\(y\\)" )
    Friends.addGame Forall 'x', Exists 'y', Caf 'x', 'y'
    Friends.addGame Forall 'x', Exists 'y', Caf 'y', 'x'
    Friends.addGame Exists 'x', Forall 'y', Caf 'x', 'y'
    Friends.addGame Forall 'x', Or Male( 'x' ), Female( 'x' )
    Friends.addGame Forall 'x', Exists 'y', \
        Implies Male( 'x' ), Caf( 'y', 'x' )
    Friends.addGame Exists 'x', Exists 'y', Exists 'z', \
        And And( Caf( 'x', 'y' ), Caf( 'y', 'z' ) ), \
            Caf( 'z', 'x' )
    Friends.addGame Exists 'x', Exists 'y', \
        And Caf( 'x', 'y' ), Caf( 'y', 'x' )

