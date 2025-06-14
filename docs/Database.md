## Supabase Previously Executed Commands

-- Enable pgvector extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS vector;

-- Create transaction embeddings table
CREATE TABLE IF NOT EXISTS transaction_embeddings (
    embedding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    
    -- Text representation of the transaction (for reference and debugging)
    transaction_text TEXT NOT NULL,
    
    -- The embedding vector (384 dimensions for all-MiniLM-L6-v2)
    embedding vector(384) NOT NULL,
    
    -- Confirmed category after user verification
    confirmed_category_id UUID REFERENCES categories(category_id),
    confirmed_category_name TEXT NOT NULL,
    
    -- Confidence score and metadata
    confidence_score FLOAT,
    embedding_model TEXT DEFAULT 'all-MiniLM-L6-v2',
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Unique constraint to prevent duplicate embeddings for same transaction
    CONSTRAINT unique_transaction_embedding UNIQUE (transaction_id)
);

-- Create index for vector similarity search
CREATE INDEX idx_transaction_embeddings_vector ON transaction_embeddings 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Create index for transaction lookups
CREATE INDEX idx_transaction_embeddings_transaction_id ON transaction_embeddings(transaction_id);

-- Update trigger for updated_at
CREATE TRIGGER update_transaction_embeddings_updated_at 
BEFORE UPDATE ON transaction_embeddings 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();

-- Function to find similar transactions
CREATE OR REPLACE FUNCTION find_similar_transactions(
    query_embedding vector(384),
    limit_count INTEGER DEFAULT 5,
    similarity_threshold FLOAT DEFAULT 0.7
)
RETURNS TABLE (
    transaction_id UUID,
    transaction_text TEXT,
    confirmed_category_id UUID,
    confirmed_category_name TEXT,
    similarity_score FLOAT,
    merchant TEXT,
    amount DECIMAL,
    date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        te.transaction_id,
        te.transaction_text,
        te.confirmed_category_id,
        te.confirmed_category_name,
        1 - (te.embedding <=> query_embedding) AS similarity_score,
        t.merchant,
        t.amount,
        t.date
    FROM transaction_embeddings te
    JOIN transactions t ON te.transaction_id = t.transaction_id
    WHERE 1 - (te.embedding <=> query_embedding) >= similarity_threshold
    ORDER BY te.embedding <=> query_embedding
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to upsert transaction embedding
CREATE OR REPLACE FUNCTION upsert_transaction_embedding(
    p_transaction_id UUID,
    p_transaction_text TEXT,
    p_embedding vector(384),
    p_category_id UUID,
    p_category_name TEXT,
    p_confidence_score FLOAT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_embedding_id UUID;
BEGIN
    INSERT INTO transaction_embeddings (
        transaction_id,
        transaction_text,
        embedding,
        confirmed_category_id,
        confirmed_category_name,
        confidence_score
    ) VALUES (
        p_transaction_id,
        p_transaction_text,
        p_embedding,
        p_category_id,
        p_category_name,
        p_confidence_score
    )
    ON CONFLICT (transaction_id) 
    DO UPDATE SET
        transaction_text = EXCLUDED.transaction_text,
        embedding = EXCLUDED.embedding,
        confirmed_category_id = EXCLUDED.confirmed_category_id,
        confirmed_category_name = EXCLUDED.confirmed_category_name,
        confidence_score = EXCLUDED.confidence_score,
        updated_at = NOW()
    RETURNING embedding_id INTO v_embedding_id;
    
    RETURN v_embedding_id;
END;
$$ LANGUAGE plpgsql;

-- Enable pgvector extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS vector;

-- Create transaction embeddings table
CREATE TABLE IF NOT EXISTS transaction_embeddings (
    embedding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    
    -- Text representation of the transaction (for reference and debugging)
    transaction_text TEXT NOT NULL,
    
    -- The embedding vector (384 dimensions for all-MiniLM-L6-v2)
    embedding vector(384) NOT NULL,
    
    -- Confirmed category after user verification
    confirmed_category_id UUID REFERENCES categories(category_id),
    confirmed_category_name TEXT NOT NULL,
    
    -- Confidence score and metadata
    confidence_score FLOAT,
    embedding_model TEXT DEFAULT 'all-MiniLM-L6-v2',
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Unique constraint to prevent duplicate embeddings for same transaction
    CONSTRAINT unique_transaction_embedding UNIQUE (transaction_id)
);

-- Create index for vector similarity search
CREATE INDEX idx_transaction_embeddings_vector ON transaction_embeddings 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Create index for transaction lookups
CREATE INDEX idx_transaction_embeddings_transaction_id ON transaction_embeddings(transaction_id);

-- Update trigger for updated_at
CREATE TRIGGER update_transaction_embeddings_updated_at 
BEFORE UPDATE ON transaction_embeddings 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();

-- Function to find similar transactions
CREATE OR REPLACE FUNCTION find_similar_transactions(
    query_embedding vector(384),
    limit_count INTEGER DEFAULT 5,
    similarity_threshold FLOAT DEFAULT 0.7
)
RETURNS TABLE (
    transaction_id UUID,
    transaction_text TEXT,
    confirmed_category_id UUID,
    confirmed_category_name TEXT,
    similarity_score FLOAT,
    merchant TEXT,
    amount DECIMAL,
    date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        te.transaction_id,
        te.transaction_text,
        te.confirmed_category_id,
        te.confirmed_category_name,
        1 - (te.embedding <=> query_embedding) AS similarity_score,
        t.merchant,
        t.amount,
        t.date
    FROM transaction_embeddings te
    JOIN transactions t ON te.transaction_id = t.transaction_id
    WHERE 1 - (te.embedding <=> query_embedding) >= similarity_threshold
    ORDER BY te.embedding <=> query_embedding
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to upsert transaction embedding
CREATE OR REPLACE FUNCTION upsert_transaction_embedding(
    p_transaction_id UUID,
    p_transaction_text TEXT,
    p_embedding vector(384),
    p_category_id UUID,
    p_category_name TEXT,
    p_confidence_score FLOAT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_embedding_id UUID;
BEGIN
    INSERT INTO transaction_embeddings (
        transaction_id,
        transaction_text,
        embedding,
        confirmed_category_id,
        confirmed_category_name,
        confidence_score
    ) VALUES (
        p_transaction_id,
        p_transaction_text,
        p_embedding,
        p_category_id,
        p_category_name,
        p_confidence_score
    )
    ON CONFLICT (transaction_id) 
    DO UPDATE SET
        transaction_text = EXCLUDED.transaction_text,
        embedding = EXCLUDED.embedding,
        confirmed_category_id = EXCLUDED.confirmed_category_id,
        confirmed_category_name = EXCLUDED.confirmed_category_name,
        confidence_score = EXCLUDED.confidence_score,
        updated_at = NOW()
    RETURNING embedding_id INTO v_embedding_id;
    
    RETURN v_embedding_id;
END;
$$ LANGUAGE plpgsql;

## Supabase Schema

create table public.categories (
  category_id uuid not null default gen_random_uuid (),
  name text not null,
  is_active boolean not null default true,
  parent_category_id uuid null,
  constraint categories_pkey primary key (category_id),
  constraint categories_parent_category_id_fkey foreign KEY (parent_category_id) references categories (category_id)
) TABLESPACE pg_default;

create table public.tags (
  tag_id uuid not null default gen_random_uuid (),
  value text not null,
  constraint tags_pkey primary key (tag_id),
  constraint tags_value_key unique (value)
) TABLESPACE pg_default;

create table public.transaction_embeddings (
  embedding_id uuid not null default gen_random_uuid (),
  transaction_id uuid not null,
  transaction_text text not null,
  embedding extensions.vector not null,
  confirmed_category_id uuid null,
  confirmed_category_name text not null,
  confidence_score double precision null,
  embedding_model text null default 'all-MiniLM-L6-v2'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint transaction_embeddings_pkey primary key (embedding_id),
  constraint unique_transaction_embedding unique (transaction_id),
  constraint transaction_embeddings_confirmed_category_id_fkey foreign KEY (confirmed_category_id) references categories (category_id),
  constraint transaction_embeddings_transaction_id_fkey foreign KEY (transaction_id) references transactions (transaction_id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_transaction_embeddings_vector on public.transaction_embeddings using ivfflat (embedding extensions.vector_cosine_ops)
with
  (lists = '100') TABLESPACE pg_default;

create index IF not exists idx_transaction_embeddings_transaction_id on public.transaction_embeddings using btree (transaction_id) TABLESPACE pg_default;

create trigger update_transaction_embeddings_updated_at BEFORE
update on transaction_embeddings for EACH row
execute FUNCTION update_updated_at_column ();

create table public.transaction_tags (
  transaction_id uuid not null,
  tag_id uuid not null,
  constraint transaction_tags_pkey primary key (transaction_id, tag_id),
  constraint transaction_tags_tag_id_fkey foreign KEY (tag_id) references tags (tag_id) on delete CASCADE,
  constraint transaction_tags_transaction_id_fkey foreign KEY (transaction_id) references transactions (transaction_id) on delete CASCADE
) TABLESPACE pg_default;

create table public.transactions (
  transaction_id uuid not null default gen_random_uuid (),
  date timestamp with time zone not null,
  amount numeric(10, 2) not null,
  merchant text null,
  category_id uuid null,
  is_recurring boolean not null default false,
  notes text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint transactions_pkey primary key (transaction_id),
  constraint transactions_category_id_fkey foreign KEY (category_id) references categories (category_id)
) TABLESPACE pg_default;

create trigger update_transactions_updated_at BEFORE
update on transactions for EACH row
execute FUNCTION update_updated_at_column ();

