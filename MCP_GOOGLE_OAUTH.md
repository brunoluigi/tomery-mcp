# MCP with Google OAuth Authentication

## Overview

The MCP endpoint now uses **Google OAuth 2.0** for authentication instead of custom tokens. MCP clients authenticate users through Google and use Google ID tokens to access MCP tools.

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐      ┌──────────────┐
│ MCP Client  │─────▶│ Google OAuth │─────▶│   User      │─────▶│ Rails MCP    │
│             │      │              │      │ Authorizes  │      │ Server       │
└─────────────┘      └──────────────┘      └─────────────┘      └──────────────┘
       │                                            │                    │
       │                                            ▼                    │
       │                                    ┌─────────────┐              │
       │                                    │ Google ID   │              │
       │◀───────────────────────────────────│ Token       │              │
       │                                    └─────────────┘              │
       │                                                                 │
       │  POST /mcp with Bearer token                                    │
       │────────────────────────────────────────────────────────────────▶│
       │                                                                 │
       │◀────────────────────────────────────────────────────────────────│
       │  MCP Response                                                   │
```

## How It Works

### 1. Discovery Phase

MCP clients discover the authorization server:

```bash
# Get protected resource metadata
GET /.well-known/oauth-protected-resource

Response:
{
  "resource": "https://yourapp.com/mcp",
  "authorization_servers": ["https://accounts.google.com"]
}
```

```bash
# Get authorization server metadata
GET /.well-known/oauth-authorization-server

Response:
{
  "issuer": "https://accounts.google.com",
  "authorization_endpoint": "https://accounts.google.com/o/oauth2/v2/auth",
  "token_endpoint": "https://oauth2.googleapis.com/token",
  "scopes_supported": ["openid", "email", "profile"]
}
```

### 2. Authorization Flow

1. **MCP Client initiates OAuth flow**
   ```
   https://accounts.google.com/o/oauth2/v2/auth?
     client_id=YOUR_GOOGLE_CLIENT_ID
     &redirect_uri=YOUR_REDIRECT_URI
     &response_type=code
     &scope=openid email profile
     &code_challenge=PKCE_CHALLENGE
     &code_challenge_method=S256
   ```

2. **User authorizes with Google**
   - User logs in to Google
   - Grants permission to the MCP client

3. **Google redirects with authorization code**
   ```
   YOUR_REDIRECT_URI?code=AUTHORIZATION_CODE&state=STATE
   ```

4. **MCP Client exchanges code for tokens**
   ```bash
   POST https://oauth2.googleapis.com/token
   
   {
     "code": "AUTHORIZATION_CODE",
     "client_id": "YOUR_GOOGLE_CLIENT_ID",
     "client_secret": "YOUR_GOOGLE_CLIENT_SECRET",
     "redirect_uri": "YOUR_REDIRECT_URI",
     "grant_type": "authorization_code",
     "code_verifier": "PKCE_VERIFIER"
   }
   
   Response:
   {
     "access_token": "...",
     "id_token": "GOOGLE_ID_TOKEN",  # This is what we use!
     "expires_in": 3600,
     "token_type": "Bearer"
   }
   ```

### 3. Using MCP Tools

MCP clients use the Google ID token to call MCP tools:

```bash
POST /mcp
Authorization: Bearer GOOGLE_ID_TOKEN
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "ListRecipesTool",
    "arguments": {}
  }
}
```

### 4. Token Validation

The Rails MCP server:
1. Extracts the Bearer token from the Authorization header
2. Validates it as a Google ID token using `google-id-token` gem
3. Extracts user email from the token
4. Finds the user in the database
5. Executes the MCP tool with the authenticated user

## Configuration

### Environment Variables

You need the same Google OAuth credentials used for web login:

```bash
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

### Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to "APIs & Services" → "Credentials"
4. Add your MCP client's redirect URI to "Authorized redirect URIs"
   - For MCP clients, this is typically a custom URI scheme or localhost

## Security Features

✅ **OAuth 2.1 with PKCE** - Protection against authorization code interception
✅ **Google ID Token Validation** - Cryptographic verification of tokens
✅ **Audience Validation** - Ensures tokens are for your app
✅ **Email-based User Lookup** - Users must exist in your database
✅ **WWW-Authenticate Headers** - Proper OAuth error responses per RFC 9728

## MCP Client Configuration

MCP clients need to be configured with:

```json
{
  "mcpServers": {
    "tomery": {
      "url": "https://yourapp.com/mcp",
      "auth": {
        "type": "oauth2",
        "client_id": "YOUR_GOOGLE_CLIENT_ID",
        "client_secret": "YOUR_GOOGLE_CLIENT_SECRET",
        "scopes": ["openid", "email", "profile"]
      }
    }
  }
}
```

## Differences from Previous Implementation

| Feature | Old (Custom Tokens) | New (Google OAuth) |
|---------|-------------------|-------------------|
| **Auth Server** | Self-hosted | Google |
| **Token Type** | Custom mcp_token | Google ID Token |
| **Token Location** | Tool arguments | Authorization header |
| **User Lookup** | By mcp_token | By email from token |
| **Token Validation** | Database lookup | Cryptographic verification |
| **Standards** | Custom | OAuth 2.1 + OpenID Connect |

## Testing

To test with a Google ID token:

```bash
# 1. Get a Google ID token (use OAuth playground or your own client)
ID_TOKEN="your_google_id_token_here"

# 2. Test the MCP endpoint
curl -X POST https://yourapp.com/mcp \
  -H "Authorization: Bearer $ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list"
  }'
```

## Troubleshooting

### "Invalid or expired access token"
- Token may be expired (Google ID tokens expire after 1 hour)
- Token audience doesn't match your GOOGLE_CLIENT_ID
- Token signature validation failed

### "User not found"
- The email in the Google token doesn't exist in your database
- User must sign up via web interface first

### "Missing or invalid Authorization header"
- Ensure you're using `Authorization: Bearer TOKEN` format
- Check that the token is being sent in the header, not in the request body

## Benefits of Google OAuth

1. **No Token Management** - No need to generate, store, or rotate MCP tokens
2. **Standard Protocol** - Full OAuth 2.1 compliance
3. **Better Security** - Cryptographic token validation
4. **Single Sign-On** - Users authenticate once with Google
5. **Token Expiration** - Automatic token expiration (1 hour)
6. **Refresh Tokens** - MCP clients can refresh expired tokens
