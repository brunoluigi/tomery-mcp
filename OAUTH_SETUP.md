# Google OAuth Setup Guide

This application uses **OmniAuth** with the `omniauth-google-oauth2` gem for Google OAuth authentication.

## Environment Variables Required

You need to set up the following environment variables:

```bash
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
```

## Getting Google OAuth Credentials

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create a New Project** (or select existing)
   - Click "Select a project" → "New Project"
   - Give it a name and click "Create"

3. **Enable Google+ API**
   - Go to "APIs & Services" → "Library"
   - Search for "Google+ API"
   - Click "Enable"

4. **Create OAuth 2.0 Credentials**
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"
   - If prompted, configure the OAuth consent screen first:
     - Choose "External" (or "Internal" if using Google Workspace)
     - Fill in required fields (App name, User support email, Developer contact)
     - Add scopes: `email` and `profile`
     - Add test users if in testing mode

5. **Configure OAuth Client**
   - Application type: "Web application"
   - Name: Your app name (e.g., "Tomery MCP")
   - Authorized JavaScript origins:
     - `http://localhost:3000` (for development)
     - Your production domain (e.g., `https://yourdomain.com`)
   - Authorized redirect URIs:
     - `http://localhost:3000/auth/google_oauth2/callback` (for development)
     - `https://yourdomain.com/auth/google_oauth2/callback` (for production)

6. **Copy Credentials**
   - After creating, you'll see your Client ID and Client Secret
   - Copy these values to your environment variables

## Setting Environment Variables

### Development (Local)

Add to your `.env` file (create if it doesn't exist):

```bash
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

**Note:** Make sure `.env` is in your `.gitignore` file!

### Production (Kamal/Docker)

Add to your `.kamal/secrets` file:

```bash
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

Or set them in your hosting platform's environment variables section.

## How It Works

1. **User Flow:**
   - User clicks "Sign in with Google" button
   - Redirected to Google's OAuth consent screen
   - After approval, Google redirects back to `/auth/google_oauth2/callback`
   - App creates or finds user by Google UID
   - User is logged in automatically

2. **Database Changes:**
   - Added `provider`, `uid`, `name`, and `image_url` columns to users table
   - `password_digest` is now nullable (OAuth users don't need passwords)
   - Added unique index on `[provider, uid]` for OAuth lookups

3. **User Model:**
   - `User.from_omniauth(auth)` - Creates or finds user from OAuth data
   - `oauth_user?` - Returns true if user signed up via OAuth
   - Password validation only applies to non-OAuth users

## Testing OAuth Locally

1. Start your Rails server:
   ```bash
   bin/dev
   ```

2. Visit: `http://localhost:3000/session/new`

3. Click "Sign in with Google"

4. You should be redirected to Google's consent screen

5. After approval, you'll be logged in and redirected to the app

## Security Notes

- OAuth tokens are handled by OmniAuth and not stored in the database
- CSRF protection is enabled via `omniauth-rails_csrf_protection`
- Always use HTTPS in production
- Keep your Client Secret secure and never commit it to version control

## Troubleshooting

### "redirect_uri_mismatch" Error
- Make sure the redirect URI in Google Console exactly matches your callback URL
- Check for trailing slashes and http vs https

### "Access Blocked" Error
- Your app might be in testing mode with limited test users
- Add your email to test users in Google Console
- Or publish your app (requires verification for production use)

### Users Can't Sign In
- Check that environment variables are set correctly
- Verify Google+ API is enabled
- Check Rails logs for detailed error messages

## Files Modified/Created

- `Gemfile` - Added omniauth gems
- `config/initializers/omniauth.rb` - OmniAuth configuration
- `app/controllers/omniauth_callbacks_controller.rb` - Handles OAuth callbacks
- `app/models/user.rb` - Added OAuth methods
- `config/routes.rb` - Added OAuth routes
- `db/migrate/XXXXXX_add_oauth_to_users.rb` - Database migration
- `app/views/sessions/new.html.erb` - Added Google sign-in button
