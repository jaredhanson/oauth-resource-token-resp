# Abstract

This document specifies a new parameter `resource` that is used to explicitly
include the resource identifier of the resource that the access token in the
token response is intended for.  This `resource` parameter serves as an
effective countermeasure to "mix-up attacks".

# Introduction

This document defines a new parameter in the token response called `resource`.
The `resource` parameter allows the authorization server to explicitly include
the identity of the protected resource(s) for which the access token is
intended.  The `resource` parameter gives the client certainty about the
protected resource(s) for which the access token is intended and enables it to
send access tokens only to the intended recipients.

# Response Parameter resource

In token responses to the client, an authorization server supporting this
specification MUST indicate the identity of the protected resource(s) for which
the access token is intended by including the `resource` parameter in the
response.

The `resource` parameter value is the resource identifier of the protected
resource(s) for which the access token is intended, as defined by [Section 2](https://datatracker.ietf.org/doc/html/rfc8707#name-resource-parameter)
of [RFC8707](https://datatracker.ietf.org/doc/html/rfc8707).  In the general
case, the `resource` parameter is an array of strings, each containing a
resource identifier.  In the special case when the access token is intended for
a single protected resource, the `resource` parameter MAY be a string.

## Example Token Response

The following example shows a token response from the authorizaiton server
where the access token is intended for the resource whose resource identifier is
`https://rs.example.com/`:

HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"2YotnFZFEjr1zCsicMWpAA",
  "token_type":"example",
  "expires_in":3600,
  "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA",
  "resource":"https://rs.example.com/"
}

## Providing the Resource Identifier

Resource servers supporting this specification MUST provide their resource
identifier to enable clients to validate the `resource` parameter effectively.
The recommended approach is [RFC9728](https://datatracker.ietf.org/doc/html/rfc9728).

TODO: Clarify this section.

## Validating the Resource Identifier

TODO: Add this section.

More precisely, clients that interact with resource servers
...

# Authorization Server Metadata

The following parameter for the authorization server metadata [RFC8414](https://datatracker.ietf.org/doc/html/rfc8414)
is introduced to signal the authorization server's support for this
specification:

`token_response_resource_parameter_supported`: Boolean parameter indicating
whether the authorization server provides the `resource` parameter in the token
response as defined in Section 2.  If omitted, the default value is false.
