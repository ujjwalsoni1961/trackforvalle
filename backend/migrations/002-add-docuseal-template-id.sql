-- Add docuseal_template_id column to contract_templates table
ALTER TABLE contract_templates ADD COLUMN IF NOT EXISTS docuseal_template_id INTEGER;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_contract_templates_docuseal_template_id ON contract_templates(docuseal_template_id);
