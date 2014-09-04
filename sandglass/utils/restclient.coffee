Promise = require( 'bluebird' )
rest = require( 'restler' )

createSuccess = ( data ) ->
  data

createFail = ( data ) ->
  data

createData = ( req ) ->
  data =
    data: req.body
    headers: req.headers

rest_init = ( app ) ->
  this.baseUrl = app.options.host

rest_defaults = {}

rest_urls =
  _user_resource_get: ( resource, req, res, get, method ) ->
    user = res.getUser()

    if not method?
      method = 'get'

    if user
      userId = user.id
    else
      userId = ''

    if not resource
      resource = ''

    new Promise ( resolve, reject ) =>
      url = "#{this.baseUrl}/users/#{userId}"

      if resource
        url += "/#{resource}"

      if get
        url += "#{get}"

      console.log( method, 'request to', url )

      @[method]( url, createData( req ) )
        .on 'success', ( result_data, raw_response ) ->
          res.set( raw_response.headers )
          res.set({
            'Content-Type': 'text/html; charset=utf-8'
            })
          resolve( createSuccess( result_data ), raw_response )
        .on 'fail', ( result_data, raw_response ) ->
          reject( createFail( result_data, raw_response ) )

  user_activities_get: ( req, res, get ) ->
    @._user_resource_get( 'activities', req, res, get )

  user_tasks_get: ( req, res, get ) ->
    @._user_resource_get( 'tasks', req, res, get )

  user_projects_get: ( req, res, get ) ->
    @._user_resource_get( 'projects', req, res, get )

  user_login_post: ( req, res, get ) ->
    @._user_resource_get( null, req, res, get, 'post' )

  auth_get: ( req, res, get ) ->
    @._user_resource_get( null, req, res, get )

module.exports = rest.service( rest_init, rest_defaults, rest_urls )
