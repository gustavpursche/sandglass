crud = require( '../utils/crud' )
date = require( '../utils/date' )
errors = require( '../errors/index' )
moment = require( 'moment' )
Promise = require( 'bluebird' )

module.exports = ( sequelize, DataTypes ) ->
  sequelize.define(
    'Activity',

    start:
      type: DataTypes.DATE
      allowNull: false

    end:
      type: DataTypes.DATE
      allowNull: true

    description:
      type: DataTypes.TEXT
      allowNull: true

    {
    classMethods:
      associate: ( models )->
        @.__models =
          Task: models.Task
          Project: models.Project
          Tag: models.Tag
          User: models.User

        @.belongsTo( models.User )
        @.belongsTo( models.Project )
        @.belongsTo( models.Task )

        @.hasMany( models.Tag )

      actionSupported: ( action, method ) ->
        action is method

      post: ( req, context ) ->
        data = req.body

        start = data.start or new Date()
        end = data.end or undefined
        description = data.description or ''

        create =
          start: start
          end: end
          description: description

        if context? and context.user?
          context_user = context.user
          create.UserId = context.user.id

        crud.CREATE.call( @, create )

      get: ( req, context, id ) ->
        includes = [ @.__models.Task,
                     @.__models.Project,
                     @.__models.Tag ]

        from = req.param( 'from' )
        to = req.param( 'to' )

        find =
          where: {}
          include: includes
          order: [
            [ 'start', 'ASC' ]
          ]

        if id?
          find.where.id = id

        if context? and context.user?
          context_user = context.user
          find.where.UserId = context_user.id

        if from
          from = date.fromString( from ).toDate()

        if to
          to = date.fromString( to ).toDate()

        if from? and to?
          find.where.start = between: [ from, to ]
        else
          if from?
            find.where.start = gt: from

          if to?
            find.where.start = lt: to

        crud.READ.call( @, find, id )

      put: ( req, context, id ) ->
        data = req.body
        find =
          where:
            id: id

        if context? and context.user?
          find.where.UserId = context.user.id

        crud.UPDATE.call( @, find, data )

      delete: ( req, context, id ) ->
        find =
          where:
            id: id

        if context? and context.user?
          find.where.UserId = context.user.id

        crud.DELETE.call( @, find, id )
    }

  )
