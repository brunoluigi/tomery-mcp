CREATE DATABASE tomery_mcp_production;
CREATE DATABASE tomery_mcp_production_cache;
CREATE DATABASE tomery_mcp_production_queue;
CREATE DATABASE tomery_mcp_production_cable;

-- Enable pgvector extension for the main database
\c tomery_mcp_production
CREATE EXTENSION IF NOT EXISTS vector;