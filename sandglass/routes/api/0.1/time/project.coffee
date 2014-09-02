express = require( 'express' )

module.exports = ( app ) ->
  express.Router()
    .get app.options.base + '/projects', [ app.sessionAuth ], ( req, res, next ) ->
      app.models.Project.get( req )
        .then( res.success, res.error )

    .get app.options.base + '/users/:userId/projects', [ app.sessionAuth ], ( req, res, next ) ->
      app.models.User.get( req, req.param( 'userId'), single: true )
        .then ( user ) ->
          app.models.Project.get( req, user: user )
        .then( res.success, res.error )

    .get app.options.base + '/users/:userId/projects/:projectId', [ app.sessionAuth ], ( req, res, next ) ->
      app.models.User.get( req, req.param( 'userId'), single: true )
        .then ( user ) ->
          app.models.Project.get( req, user: user, req.param( 'projectId' ) )
        .then( res.success, res.error )
