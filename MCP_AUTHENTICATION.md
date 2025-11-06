# MCP Authentication

## Overview

The Tomery MCP server uses token-based authentication. Each user session has a unique `mcp_token` that must be included in the Authorization header.

## How It Works

### 1. Get Your MCP Token

When a user signs in (via password or Google OAuth), a session is created with a unique `mcp_token`. This token can be found in the database:

```ruby
# In Rails console
user = User.find_by(email_address: "your@email.com")
session = user.sessions.last
puts session.mcp_token
```

### 2. Configure Your MCP Client

Add the Tomery MCP server to your MCP client configuration with your token:

```json
{
  "mcpServers": {
    "tomery": {
      "url": "https://tomery.passionfruits.dev/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_MCP_TOKEN_HERE"
      }
    }
  }
}
```

For local development:

```json
{
  "mcpServers": {
    "tomery-local": {
      "url": "http://localhost:3000/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_MCP_TOKEN_HERE"
      }
    }
  }
}
```

### 3. Using MCP Tools

Once configured, your MCP client can call any of the available tools:

```bash
POST /mcp
Authorization: Bearer YOUR_MCP_TOKEN
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list"
}
```

## Available Tools

- **Recipe Management**: `AddRecipeTool`, `ListRecipesTool`, `ShowRecipeTool`, `UpdateRecipeTool`, `RemoveRecipeTool`
- **Pantry Management**: `AddPantryItemsTool`, `ListPantryItemsTool`, `UpdatePantryItemQuantityTool`, `RemovePantryItemsTool`
- **Meal Planning**: `AddMealPlansTool`, `ListMealPlansTool`, `RemoveMealPlansTool`

## Security Notes

- MCP tokens are stored securely in the database
- Each token is unique per session (36 characters)
- Tokens are transmitted via Bearer authentication
- Keep your token secure - don't commit it to version control

## Troubleshooting

### "Missing or invalid Authorization header"
- Ensure you're using `Authorization: Bearer TOKEN` format
- Check that the token is correct (no extra spaces or characters)

### "Invalid or expired access token"
- The token may not exist in the database
- The associated session may have been deleted
- Generate a new token by signing in again

## Testing

To test the MCP endpoint with curl:

```bash
TOKEN="your_mcp_token_here"

curl -X POST http://localhost:3000/mcp \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list"
  }'
```
