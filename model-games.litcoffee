
This file (after being compiled to JavaScript) can be loaded into
a web page and allows the user to do several things related to
the game-theoretic semantics for predicate logic.

It depends on a few basic functions for building logical
expressions:

    window.And = ( a, b ) -> [ 'And', a, b ]
    window.Or = ( a, b ) -> [ 'Or', a, b ]
    window.Not = ( a ) -> [ 'Not', a ]
    window.Implies = ( a, b ) -> [ 'Implies', a, b ]
    window.Iff = ( a, b ) -> [ 'Iff', a, b ]
    window.Forall = ( a, b ) -> [ 'Forall', a, b ]
    window.Exists = ( a, b ) -> [ 'Exists', a, b ]

First, you can create a new model in which to play games, as
follows.

```
M = new Model( 'name', 'description', universe )
```

For example, you might call it "The Real Numbers" and then in the
description (which can include basic HTML) you can describe in a
few sentences which operators it includes, and so on.  The third
argument is a function that takes a single JavaScript datum as
input and returns true or false, whether that thing is in the
universe of the model.  For example, for numbers, you might have
`( x ) -> typeof( x ) is 'number'`.

You can add new operators to the language of the model as
follows.

```
Op1 = M.addOperator( latex, evaluate, precedence,
                     explanation, argNames )
```

LaTeX must be a function that takes as many arguments as the
operator and creates a text representation of them in LaTeX
format.  Evaluate must be a function that computes the result
of the operator, in JavaScript.  And precedence, which is
optional, must be a number; higher means higher precedence.
If it is omitted, no parenthesization will be used.  The result
is a function that can be used to build expressions with that
operator as the head.  The explanation will be HTML/LaTeX text
explaining the meaning of the operator applied to sample args
named x, y, z.  If you want to use other args, supply them as the
final parameter.  LaTeX delimiters are `\(` and `\)`.
Example:

```
gt = M.addOperator( ( ( a, b ) -> "#{a} > #{b}" ),
                    ( ( a, b ) -> a > b ),
                    10,
                    '\\(x\\) is greater than \\(y\\),
                     \\(x > y\\)' )
```

You can add a constant the same way, but its LaTeX and value
are both JavaScript constants, not functions.  The first argument
is how a user woult type it in when playing the game.

```
pi = M.addConstant( 'pi', '\\pi', Math.pi )
```

Finally, you can add games to the model by writing expressions
(in prefix form, in JavaScript/CoffeeScript) and adding them to
the model with the `addGame` method.  All the predicate logic
connectives are defined already as functions (`And`, `Or`, `Not`,
`Implies`, `Iff`) and the quantifiers are as well (`Forall`,
`Exists`).  Variables should be strings (such as `"x"`) and other
literals or strings accepted by your model's universe function are
acceptable.

```
M.addGame( Forall( 'x', Foo( Con, 'x' ) ) )
// and so on, as many games in topic t as you like
```

    window.Model = class Model

        allModels: [ ]

        constructor: ( @name, @description, @universe ) ->
            Model::allModels.push @
            @operators = [ ]
            @constants = [ ]
            @expressions = [ ]

        addOperator: ( latex, evaluate, precedence, explanation,
                       exampleArgs = [ 'x', 'y', 'z' ] ) ->
            @operators.push
                latex : latex
                evaluate : evaluate
                precedence : precedence
                exampleArgs : exampleArgs
                explanation : explanation
            head = "op#{@operators.length - 1}"
            ( args... ) -> [ head, args... ]

        addConstant: ( text, latex, value ) ->
            @constants.push
                text : text
                latex : latex
                value : value
            "con#{@constants.length - 1}"

        addGame: ( expression ) ->
            @expressions.push expression

        toLaTeX: ( expression, precedence ) ->
            # console.log 'toLaTeX', JSON.stringify( expression ),
            #     precedence
            if typeof( precedence ) is 'undefined'
                precedence = 'top' # but null is okay!!
            wrap = ( result ) ->
                if precedence is 'top'
                    '\\(' + result + '\\)'
                else
                    result
            if expression not instanceof Array
                if expression in \
                ( "con#{i}" for i in [0...@constants.length] )
                    expression =
                        @constants[expression[3..]].latex
                # console.log 'atomic', expression
                return wrap expression
            expression = expression.slice()
            head = expression.shift()
            pattern = null
            if head is 'And'
                pattern = "A \\wedge B"
                prec = -990
            if head is 'Or'
                pattern = "A \\vee B"
                prec = -1000
            if head is 'Not'
                pattern = "\\neg A"
                prec = -900
            if head is 'Implies'
                pattern = "A \\Rightarrow B"
                prec = -1005
            if head is 'Iff'
                pattern = "A \\Leftrightarrow B"
                prec = -1010
            if head is 'Forall'
                pattern = "\\forall A, B"
                prec = -950
            if head is 'Exists'
                pattern = "\\exists A, B"
                prec = -950
            if pattern?
                # console.log 'pattern', pattern
                func = ( a, b ) ->
                    pattern.replace( 'A', a )
                           .replace( 'B', b )
            else if head[...2] is 'op'
                func = @operators[head[2..]].latex
                prec = @operators[head[2..]].precedence
                # console.log head, @operators[head[2..]]
            else
                func = -> '???'
            args = ( @toLaTeX expr, prec for expr in expression )
            # console.log 'func', func, 'args', args
            result = func args...
            if typeof precedence is 'number' \
            and prec < precedence
                result = "\\left(#{result}\\right)"
            # console.log 'result', result
            wrap result

        interpretations: ->
            result = '<table border=0 align=center
                       style="border-spacing: 20px;
                              border-collapse: separate;">'
            result += "<tr>
                <td align=right>UD:</td>
                <td>#{@name}</td></tr>"
            for operator in @operators
                latex = operator.latex operator.exampleArgs...
                result += "<tr>
                    <td align=right>\\(#{latex}\\)</td>
                    <td>#{operator.explanation}</td></tr>"
            for constant in @constants
                result += "<tr>
                    <td align=right>\\(#{constant.latex}\\)</td>
                    <td>#{constant.value}, which you type in as
                        #{constant.text}</td></tr>"
            result + '</table>'

        gameLaTeX: ( index ) -> @toLaTeX @expressions[index]

        gameList: ->
            result = '<ol>'
            here = thisPageURL()
            for game, index in @expressions
                result += "<li><a href='#{here}&game=#{index}'
                    >#{@gameLaTeX index}</a></li>"
            result + '</ol>'

        gameInputs: ( index ) ->
            seenForall = seenExists = no
            getVars = ( expression ) ->
                if expression not instanceof Array or \
                   expression[0] not in [ 'Forall', 'Exists' ]
                    return [ ]
                if expression[0] is 'Forall'
                    seenForall = yes
                else
                    seenExists = yes
                [
                    name : expression[1]
                    quantifier : expression[0]
                ].concat getVars expression[2]
            variables = getVars @expressions[index]
            result = '<form class="form-horizontal">'
            for variable, index in variables
                intro = if variables.length > 1
                    if index is 0 then 'First, ' else 'Then, '
                else
                    'Only one step: '
                player = if variable.quantifier is 'Forall' \
                    then 'Challenger' else 'Defender'
                result += "<div class='form-group'>
                    <label for='bound_var_#{variable.name}'
                           class='col-sm-6 control-label'
                     >#{intro} the #{player} chooses the value
                      of #{variable.name}:</label>
                    <div class='col-sm-4'>
                        <input type=text value=''
                         class='form-control player-input'
                         data-player='#{player}'
                         id='bound_var_#{variable.name}'
                         size=15>
                    </div>
                    </div>"
            if not seenForall
                if not seenExists
                    result += '
                        <div class="col-sm-12 control-label"
                             style="text-align: center;">
                            Neither player makes a play in
                            this game; it has no quantifiers.
                        </div>'
                else
                    result += '
                        <div class="col-sm-12 control-label"
                             style="text-align: center;">
                            The Challenger does not play in this
                            game.
                        </div>'
            else if not seenExists
                result += '
                    <div class="col-sm-12 control-label"
                         style="text-align: center;">
                        The Defender does not play in this game.
                    </div>'
            result + '</form>'

        evaluate: ( gameIndex ) ->
            getVar = ( name ) ->
                input = document.getElementById \
                    "bound_var_#{name}"
                input?.value
            recur = ( expr ) =>
                #console.log 'evaluating', JSON.stringify expr
                if expr not instanceof Array
                    if expr in ( "con#{i}" \
                    for i in [0...@constants.length] )
                        return @constants[expr[3..]].value
                    if tryvar = getVar expr
                        return tryvar
                    if @universe expr
                        return expr
                    throw "Invalid value: #{expr}"
                expr = expr.slice()
                head = expr.shift()
                rest = ( recur subexpr for subexpr in expr )
                #console.log 'now back to applying', head, 'to',
                #    rest
                switch head
                    when 'And' then return rest[0] and rest[1]
                    when 'Or' then return rest[0] or rest[1]
                    when 'Not' then return not rest[0]
                    when 'Implies'
                        return not rest[0] or rest[1]
                    when 'Iff' then return rest[0] is rest[1]
                    when 'Forall', 'Exists' then return rest[1]
                    else
                        if head[...2] isnt 'op'
                            throw "Unknown operator: #{head}"
                #console.log 'looking up', head[2..], 'gives',
                #    @operators[head[2..]], 'which evaluates as',
                #    @operators[head[2..]].evaluate
                @operators[head[2..]]?.evaluate? rest...
            recur @expressions[gameIndex]

        gameResults: ( index ) ->
            "<form class='form-horizontal'>
                <div class='form-group'>
                    <label for='judge_button'
                           class='col-sm-6 control-label'
                    >After all plays have been made:</label>
                    <div class='col-sm-6'>
                        <button type='submit' id='judge_button'
                                class='btn btn-default'
                        >Judge winner</button>
                    </div>
                </div>
            </form>
            <div class='alert alert-warning'
                id='game_result' role='alert'
                style='text-align: center;'>
                (The result of the game will be shown here.)
            </div>"

Then your HTML file can mark a specific element with the id
modelList, and the library will auto-populate it with a list of
all defined models, each as a link.

The links will go to this same HTML file, but with the query
string saying `?model=<index>`.

    $ ->
        here = thisPageURL()
        if fillMe = document.getElementById 'modelList'
            fillMe.innerHTML = '<ul></ul>'
            for index, model of Model::allModels
                item = document.createElement 'li'
                item.innerHTML = "<a
                    href='#{here}?model=#{index}'
                    >#{model.name}</a> (#{model.description})"
                fillMe.childNodes[0].appendChild item

The library, if it notices that the query string has that format,
will replace the entire body of the page with the definition of
that topic and the list of all games in it.

Each game in that list will also be a link to the same HTML file,
but with the query string saying `?model=<index>&game=<index>`.

        return unless ( mark = here.indexOf '?' ) > -1
        queryString = here.substring mark + 1
        withoutQS = here.substring 0, mark
        params = { }
        for param in queryString.split '&'
            halves = param.split '='
            params[halves[0]] = halves[1]
        { model, game } = params
        return unless model?
        halfQS = "#{withoutQS}?model=#{model}"
        model = Model::allModels[model]
        if not game?
            newBody = "
                <div class='container'>
                    <div class='jumbotron'>
                        <h2>Model: #{model.name}</h2>
                        <p>(#{model.description})</p>
                        <h2>Games listed below.</h2>
                        <p><a href='#{withoutQS}'>&larr;
                            Return to main page</a></p>
                    </div>
                    <div class='panel panel-info'>
                        <div class='panel-heading'>
                            <h3>Interpretations</h3>
                        </div>
                        <div class='panel-body'>
                            #{model.interpretations()}
                        </div>
                    </div>
                    <div class='panel panel-success'>
                        <div class='panel-heading'>
                            <h3>Games on this model</h3>
                        </div>
                        <div class='panel-body'>
                            #{model.gameList()}
                        </div>
                    </div>
                </div>"

The library, if it notices that the query string has that format,
will replace the entire body of the page with the game UI.

        else
            newBody = "
                <div class='container'>
                    <div class='jumbotron'>
                        <h2>Model: #{model.name}</h2>
                        <h2>Game: #{model.gameLaTeX game}</h2>
                        <p>(#{model.description})</p>
                        <p><a href='#{halfQS}'>&larr;
                            Return to game
                            list for this model</a></p>
                        <p><a href='#{withoutQS}'>&larr;
                            Return to main page</a></p>
                    </div>
                    <div class='panel panel-info'>
                        <div class='panel-heading'>
                            <h3>Interpretations</h3>
                        </div>
                        <div class='panel-body'>
                            #{model.interpretations()}
                        </div>
                    </div>
                    <div class='panel panel-success'>
                        <div class='panel-heading'>
                            <h3>Game Play</h3>
                        </div>
                        <div class='panel-body'>
                            #{model.gameInputs game}
                        </div>
                    </div>
                    <div class='panel panel-warning'>
                        <div class='panel-heading'>
                            <h3>Game Results</h3>
                        </div>
                        <div class='panel-body'>
                            #{model.gameResults game}
                        </div>
                    </div>
                </div>"
        document.body.innerHTML = newBody
        judgeButton = document.getElementById 'judge_button'
        gameResult = document.getElementById 'game_result'
        if judgeButton? and gameResult?
            ( $ judgeButton ).on 'click', ->
                try
                    inputs = document.getElementsByClassName \
                        'player-input'
                    for input in inputs
                        if not model.universe input.value
                            varname = input.id[10..]
                            player = input.getAttribute \
                                'data-player'
                            other = if player is 'Challenger'
                                'Defender'
                            else
                                'Challenger'
                            gameResult.innerHTML =
                                "<h4>The #{player}'s input for
                                the variable #{varname} was
                                invalid, so the #{other}
                                wins.</h4>"
                            return no
                    gameResult.innerHTML = if model.evaluate game
                        '<h4>The expression is true.
                         The Defender wins!</h4>'
                    else
                        '<h4>The expression is false.
                         The Challenger wins!</h4>'
                catch e
                    console.log e
                return no

Thus the library could be loaded from GitHub as if it were a CDN,
and the page itself would simply contain some HTML introducing
model games, and the JS/CS defining the topics and their games.

A utility function:

    thisPageURL = ->
        window.location.href.replace( "'", escape "'" )
                             .replace( "<", escape "<" )
                             .replace( ">", escape ">" )

