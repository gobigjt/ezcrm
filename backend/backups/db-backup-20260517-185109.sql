--
-- PostgreSQL database dump
--

\restrict wlcFucuztKtrfCQcFaO5rQwUOVXgqFY1fq1ladgi6EuVWEC5JrJoApvWcAhZZyq

-- Dumped from database version 18.3 (Debian 18.3-1.pgdg13+1)
-- Dumped by pg_dump version 18.4 (Debian 18.4-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: sync_user_role_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sync_user_role_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.role_id IS DISTINCT FROM OLD.role_id THEN
    SELECT name INTO NEW.role FROM roles WHERE id = NEW.role_id;
  END IF;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(200) NOT NULL,
    type character varying(30) NOT NULL,
    parent_id integer,
    is_active boolean DEFAULT true NOT NULL,
    tenant_id integer NOT NULL,
    CONSTRAINT accounts_type_check CHECK (((type)::text = ANY (ARRAY[('asset'::character varying)::text, ('liability'::character varying)::text, ('equity'::character varying)::text, ('income'::character varying)::text, ('expense'::character varying)::text])))
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendance (
    id integer NOT NULL,
    date date NOT NULL,
    check_in time without time zone,
    check_out time without time zone,
    status character varying(20) DEFAULT 'present'::character varying NOT NULL,
    notes text,
    user_id integer NOT NULL,
    tenant_id integer NOT NULL,
    CONSTRAINT attendance_status_check CHECK (((status)::text = ANY (ARRAY[('present'::character varying)::text, ('absent'::character varying)::text, ('half_day'::character varying)::text, ('leave'::character varying)::text, ('holiday'::character varying)::text])))
);


--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer,
    action character varying(100) NOT NULL,
    module character varying(100),
    record_id integer,
    details jsonb,
    ip_address character varying(45),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: bom; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bom (
    id integer NOT NULL,
    product_id integer NOT NULL,
    name character varying(200) NOT NULL,
    version character varying(20) DEFAULT '1.0'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bom_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bom_id_seq OWNED BY public.bom.id;


--
-- Name: bom_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bom_items (
    id integer NOT NULL,
    bom_id integer NOT NULL,
    component_id integer NOT NULL,
    quantity numeric(15,3) NOT NULL,
    unit character varying(30) DEFAULT 'pcs'::character varying NOT NULL
);


--
-- Name: bom_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bom_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bom_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bom_items_id_seq OWNED BY public.bom_items.id;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brands (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.brands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.brands_id_seq OWNED BY public.brands.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: comm_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comm_logs (
    id integer NOT NULL,
    lead_id integer,
    channel character varying(30) NOT NULL,
    recipient character varying(255) NOT NULL,
    subject character varying(255),
    body text,
    status character varying(30) DEFAULT 'sent'::character varying NOT NULL,
    sent_by integer,
    sent_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: comm_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comm_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comm_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comm_logs_id_seq OWNED BY public.comm_logs.id;


--
-- Name: comm_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comm_templates (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    channel character varying(30) NOT NULL,
    subject character varying(255),
    body text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer,
    CONSTRAINT comm_templates_channel_check CHECK (((channel)::text = ANY (ARRAY[('whatsapp'::character varying)::text, ('email'::character varying)::text, ('sms'::character varying)::text])))
);


--
-- Name: comm_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comm_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comm_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comm_templates_id_seq OWNED BY public.comm_templates.id;


--
-- Name: company_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company_settings (
    id integer NOT NULL,
    company_name character varying(200) NOT NULL,
    gstin character varying(15),
    address text,
    phone character varying(20),
    email character varying(255),
    logo_url text,
    currency character varying(10) DEFAULT 'INR'::character varying NOT NULL,
    fiscal_year_start date,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    invoice_tagline text,
    payment_terms text,
    invoice_bank_details text,
    bank_name character varying(200),
    bank_branch character varying(200),
    bank_account_number character varying(80),
    bank_ifsc character varying(20),
    favicon_url text,
    invoice_logo_url text,
    tenant_id integer,
    invoice_footer_content text
);


--
-- Name: company_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.company_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: company_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.company_settings_id_seq OWNED BY public.company_settings.id;


--
-- Name: crm_platforms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crm_platforms (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: crm_platforms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crm_platforms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crm_platforms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crm_platforms_id_seq OWNED BY public.crm_platforms.id;


--
-- Name: crm_priorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crm_priorities (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    color character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: crm_priorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crm_priorities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crm_priorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crm_priorities_id_seq OWNED BY public.crm_priorities.id;


--
-- Name: crm_segments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crm_segments (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: crm_segments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crm_segments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crm_segments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crm_segments_id_seq OWNED BY public.crm_segments.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    email character varying(255),
    phone character varying(20),
    gstin character varying(15),
    lead_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by integer,
    billing_address text,
    shipping_address text,
    tenant_id integer
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    user_id integer,
    employee_code character varying(30) NOT NULL,
    department character varying(100),
    designation character varying(100),
    date_of_joining date,
    date_of_birth date,
    phone character varying(20),
    address text,
    bank_account character varying(50),
    ifsc_code character varying(20),
    pan_number character varying(10),
    basic_salary numeric(15,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.expenses (
    id integer NOT NULL,
    account_id integer,
    amount numeric(15,2) NOT NULL,
    expense_date date DEFAULT CURRENT_DATE NOT NULL,
    category character varying(100),
    description text,
    receipt_url text,
    approved_by integer,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


--
-- Name: grn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grn (
    id integer NOT NULL,
    grn_number character varying(50) NOT NULL,
    po_id integer NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    created_by integer,
    tenant_id integer NOT NULL
);


--
-- Name: grn_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grn_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grn_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grn_id_seq OWNED BY public.grn.id;


--
-- Name: grn_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grn_items (
    id integer NOT NULL,
    grn_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity numeric(15,3) NOT NULL,
    warehouse_id integer NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: grn_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grn_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grn_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grn_items_id_seq OWNED BY public.grn_items.id;


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_items (
    id integer NOT NULL,
    invoice_id integer NOT NULL,
    product_id integer,
    description text NOT NULL,
    quantity numeric(15,3) NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    gst_rate numeric(5,2) DEFAULT 0 NOT NULL,
    cgst numeric(15,2) DEFAULT 0 NOT NULL,
    sgst numeric(15,2) DEFAULT 0 NOT NULL,
    igst numeric(15,2) DEFAULT 0 NOT NULL,
    total numeric(15,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL
);


--
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoice_items_id_seq OWNED BY public.invoice_items.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    invoice_number character varying(50) NOT NULL,
    customer_id integer NOT NULL,
    order_id integer,
    invoice_date date DEFAULT CURRENT_DATE NOT NULL,
    due_date date,
    subtotal numeric(15,2) DEFAULT 0 NOT NULL,
    cgst numeric(15,2) DEFAULT 0 NOT NULL,
    sgst numeric(15,2) DEFAULT 0 NOT NULL,
    igst numeric(15,2) DEFAULT 0 NOT NULL,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'unpaid'::character varying NOT NULL,
    notes text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    reference_no character varying(100),
    gst_type character varying(20) DEFAULT 'intra_state'::character varying NOT NULL,
    tax_type character varying(20) DEFAULT 'exclusive'::character varying NOT NULL,
    discount_type character varying(10) DEFAULT 'percentage'::character varying NOT NULL,
    discount_amount numeric(15,2) DEFAULT 0 NOT NULL,
    shipping_amount numeric(15,2) DEFAULT 0 NOT NULL,
    extra_discount numeric(15,2) DEFAULT 0 NOT NULL,
    round_off numeric(10,2) DEFAULT 0 NOT NULL,
    payment_terms character varying(50),
    payment_method character varying(50),
    state_of_supply character varying(50),
    approval_status character varying(20) DEFAULT 'approved'::character varying NOT NULL,
    approved_by integer,
    approved_at timestamp with time zone,
    tenant_id integer,
    CONSTRAINT invoices_approval_status_check CHECK (((approval_status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text]))),
    CONSTRAINT invoices_status_check CHECK (((status)::text = ANY (ARRAY[('unpaid'::character varying)::text, ('partial'::character varying)::text, ('paid'::character varying)::text])))
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: journal_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_entries (
    id integer NOT NULL,
    entry_date date DEFAULT CURRENT_DATE NOT NULL,
    reference character varying(200),
    description text NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: journal_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journal_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journal_entries_id_seq OWNED BY public.journal_entries.id;


--
-- Name: journal_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_lines (
    id integer NOT NULL,
    entry_id integer NOT NULL,
    account_id integer NOT NULL,
    debit numeric(15,2) DEFAULT 0 NOT NULL,
    credit numeric(15,2) DEFAULT 0 NOT NULL,
    description text,
    tenant_id integer NOT NULL
);


--
-- Name: journal_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.journal_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.journal_lines_id_seq OWNED BY public.journal_lines.id;


--
-- Name: lead_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_activities (
    id integer NOT NULL,
    lead_id integer NOT NULL,
    user_id integer,
    type character varying(50) NOT NULL,
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: lead_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_activities_id_seq OWNED BY public.lead_activities.id;


--
-- Name: lead_followups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_followups (
    id integer NOT NULL,
    lead_id integer NOT NULL,
    assigned_to integer,
    due_date timestamp with time zone NOT NULL,
    description text,
    is_done boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: lead_followups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_followups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_followups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_followups_id_seq OWNED BY public.lead_followups.id;


--
-- Name: lead_form_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_form_submissions (
    id integer NOT NULL,
    form_id integer NOT NULL,
    data jsonb NOT NULL,
    lead_id integer,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: lead_form_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_form_submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_form_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_form_submissions_id_seq OWNED BY public.lead_form_submissions.id;


--
-- Name: lead_forms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_forms (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    fields jsonb DEFAULT '[]'::jsonb NOT NULL,
    source character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    title character varying(255),
    form_key character varying(100),
    default_source_id integer,
    default_stage_id integer,
    assigned_to integer
);


--
-- Name: lead_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_forms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_forms_id_seq OWNED BY public.lead_forms.id;


--
-- Name: lead_platform_facebook_leads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_platform_facebook_leads (
    id integer NOT NULL,
    page_id character varying(50) NOT NULL,
    form_id character varying(50) NOT NULL,
    facebook_lead_id character varying(50) NOT NULL,
    created_time timestamp with time zone,
    field_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    raw_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    crm_lead_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer DEFAULT 1
);


--
-- Name: lead_platform_facebook_leads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_platform_facebook_leads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_platform_facebook_leads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_platform_facebook_leads_id_seq OWNED BY public.lead_platform_facebook_leads.id;


--
-- Name: lead_platform_facebook_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_platform_facebook_pages (
    id integer NOT NULL,
    page_id character varying(50) NOT NULL,
    page_name character varying(200),
    page_access_token text,
    lead_source_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    page_url character varying(500),
    tenant_id integer DEFAULT 1
);


--
-- Name: lead_platform_facebook_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_platform_facebook_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_platform_facebook_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_platform_facebook_pages_id_seq OWNED BY public.lead_platform_facebook_pages.id;


--
-- Name: lead_platform_google_sheets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_platform_google_sheets (
    id integer NOT NULL,
    sheet_url text NOT NULL,
    sheet_gid character varying(50),
    lead_source_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    data_start_row integer,
    tenant_id integer DEFAULT 1
);


--
-- Name: lead_platform_google_sheets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_platform_google_sheets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_platform_google_sheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_platform_google_sheets_id_seq OWNED BY public.lead_platform_google_sheets.id;


--
-- Name: lead_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_sources (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


--
-- Name: lead_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_sources_id_seq OWNED BY public.lead_sources.id;


--
-- Name: lead_stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_stages (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: lead_stages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_stages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_stages_id_seq OWNED BY public.lead_stages.id;


--
-- Name: leads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leads (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    email character varying(255),
    phone character varying(20),
    company character varying(200),
    source_id integer,
    stage_id integer,
    assigned_to integer,
    custom_fields jsonb,
    notes text,
    is_converted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    priority character varying(10) DEFAULT 'warm'::character varying NOT NULL,
    lead_score numeric(6,2) DEFAULT 0 NOT NULL,
    lead_segment character varying(10),
    job_title character varying(150),
    deal_size numeric(15,2),
    website character varying(500),
    address text,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    assigned_manager_id integer,
    created_by integer,
    product_category character varying(150),
    tenant_id integer,
    shipping_address text,
    CONSTRAINT leads_priority_check CHECK (((priority)::text = ANY (ARRAY[('hot'::character varying)::text, ('warm'::character varying)::text, ('cold'::character varying)::text])))
);


--
-- Name: leads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leads_id_seq OWNED BY public.leads.id;


--
-- Name: module_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_settings (
    id integer NOT NULL,
    module character varying(50) NOT NULL,
    label character varying(100) NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    allowed_roles text[] DEFAULT ARRAY['Super Admin'::text, 'Admin'::text, 'Manager'::text, 'Agent'::text, 'Accountant'::text, 'HR'::text] NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: module_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.module_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: module_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.module_settings_id_seq OWNED BY public.module_settings.id;


--
-- Name: notification_push_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_push_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token text NOT NULL,
    platform character varying(32),
    is_active boolean DEFAULT true NOT NULL,
    last_seen_at timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: notification_push_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_push_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_push_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_push_tokens_id_seq OWNED BY public.notification_push_tokens.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(255) NOT NULL,
    body text,
    type character varying(50) DEFAULT 'info'::character varying NOT NULL,
    module character varying(50),
    link text,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    invoice_id integer NOT NULL,
    amount numeric(15,2) NOT NULL,
    payment_date date DEFAULT CURRENT_DATE NOT NULL,
    method character varying(50) DEFAULT 'bank_transfer'::character varying NOT NULL,
    reference character varying(200),
    notes text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: payroll; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payroll (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    basic numeric(15,2) DEFAULT 0 NOT NULL,
    hra numeric(15,2) DEFAULT 0 NOT NULL,
    allowances numeric(15,2) DEFAULT 0 NOT NULL,
    deductions numeric(15,2) DEFAULT 0 NOT NULL,
    pf numeric(15,2) DEFAULT 0 NOT NULL,
    gross numeric(15,2) DEFAULT 0 NOT NULL,
    net numeric(15,2) DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    paid_on date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL,
    CONSTRAINT payroll_month_check CHECK (((month >= 1) AND (month <= 12))),
    CONSTRAINT payroll_status_check CHECK (((status)::text = ANY (ARRAY[('draft'::character varying)::text, ('processed'::character varying)::text, ('paid'::character varying)::text])))
);


--
-- Name: payroll_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payroll_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payroll_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payroll_id_seq OWNED BY public.payroll.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    module character varying(100) NOT NULL,
    action character varying(50) NOT NULL,
    label character varying(200)
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    sku character varying(100),
    hsn_code character varying(20),
    description text,
    unit character varying(30) DEFAULT 'pcs'::character varying NOT NULL,
    purchase_price numeric(15,2) DEFAULT 0 NOT NULL,
    sale_price numeric(15,2) DEFAULT 0 NOT NULL,
    gst_rate numeric(5,2) DEFAULT 0 NOT NULL,
    low_stock_alert integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    code character varying(100),
    category character varying(120),
    brand_id integer,
    image_url text,
    tenant_id integer NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: proposal_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proposal_items (
    id integer NOT NULL,
    proposal_id integer NOT NULL,
    product_id integer,
    description text NOT NULL,
    quantity numeric(15,3) NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    gst_rate numeric(5,2) DEFAULT 0 NOT NULL,
    total numeric(15,2) NOT NULL
);


--
-- Name: proposal_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proposal_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposal_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proposal_items_id_seq OWNED BY public.proposal_items.id;


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proposals (
    id integer NOT NULL,
    proposal_number character varying(50) NOT NULL,
    customer_id integer NOT NULL,
    lead_id integer,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    valid_until date,
    notes text,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT proposals_status_check CHECK (((status)::text = ANY (ARRAY[('draft'::character varying)::text, ('sent'::character varying)::text, ('accepted'::character varying)::text, ('rejected'::character varying)::text])))
);


--
-- Name: proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proposals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proposals_id_seq OWNED BY public.proposals.id;


--
-- Name: purchase_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_invoices (
    id integer NOT NULL,
    invoice_number character varying(50) NOT NULL,
    vendor_id integer NOT NULL,
    po_id integer,
    invoice_date date NOT NULL,
    due_date date,
    amount numeric(15,2) DEFAULT 0 NOT NULL,
    gst_amount numeric(15,2) DEFAULT 0 NOT NULL,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'unpaid'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL,
    CONSTRAINT purchase_invoices_status_check CHECK (((status)::text = ANY (ARRAY[('unpaid'::character varying)::text, ('partial'::character varying)::text, ('paid'::character varying)::text])))
);


--
-- Name: purchase_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_invoices_id_seq OWNED BY public.purchase_invoices.id;


--
-- Name: purchase_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_order_items (
    id integer NOT NULL,
    po_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity numeric(15,3) NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    gst_rate numeric(5,2) DEFAULT 0 NOT NULL,
    total numeric(15,2) NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_order_items_id_seq OWNED BY public.purchase_order_items.id;


--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.purchase_orders (
    id integer NOT NULL,
    po_number character varying(50) NOT NULL,
    vendor_id integer NOT NULL,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    expected_date date,
    notes text,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL,
    CONSTRAINT purchase_orders_status_check CHECK (((status)::text = ANY (ARRAY[('draft'::character varying)::text, ('sent'::character varying)::text, ('partial'::character varying)::text, ('received'::character varying)::text, ('cancelled'::character varying)::text])))
);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.purchase_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.purchase_orders_id_seq OWNED BY public.purchase_orders.id;


--
-- Name: quotation_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotation_items (
    id integer NOT NULL,
    quotation_id integer NOT NULL,
    product_id integer,
    description text NOT NULL,
    quantity numeric(15,3) NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    gst_rate numeric(5,2) DEFAULT 0 NOT NULL,
    total numeric(15,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL,
    cgst numeric(15,2) DEFAULT 0 NOT NULL,
    sgst numeric(15,2) DEFAULT 0 NOT NULL,
    igst numeric(15,2) DEFAULT 0 NOT NULL
);


--
-- Name: quotation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quotation_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quotation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quotation_items_id_seq OWNED BY public.quotation_items.id;


--
-- Name: quotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotations (
    id integer NOT NULL,
    quotation_number character varying(50) NOT NULL,
    customer_id integer NOT NULL,
    proposal_id integer,
    status character varying(30) DEFAULT 'draft'::character varying NOT NULL,
    valid_until date,
    notes text,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    exchange_rate numeric(10,4) DEFAULT 1 NOT NULL,
    state_of_supply character varying(50),
    discount_amount numeric(15,2) DEFAULT 0 NOT NULL,
    round_off numeric(10,2) DEFAULT 0 NOT NULL,
    billing_name character varying(200),
    billing_phone character varying(30),
    billing_email character varying(200),
    billing_address text,
    billing_state character varying(50),
    delivery_same_as_billing boolean DEFAULT true NOT NULL,
    delivery_name character varying(200),
    delivery_phone character varying(30),
    delivery_email character varying(200),
    delivery_address text,
    delivery_state character varying(50),
    gst_type character varying(20) DEFAULT 'intra_state'::character varying NOT NULL,
    tax_type character varying(20) DEFAULT 'exclusive'::character varying NOT NULL,
    is_interstate boolean DEFAULT false NOT NULL,
    subtotal numeric(15,2) DEFAULT 0 NOT NULL,
    cgst numeric(15,2) DEFAULT 0 NOT NULL,
    sgst numeric(15,2) DEFAULT 0 NOT NULL,
    igst numeric(15,2) DEFAULT 0 NOT NULL,
    approval_status character varying(20) DEFAULT 'approved'::character varying NOT NULL,
    approved_by integer,
    approved_at timestamp with time zone,
    tenant_id integer,
    sales_executive_id integer,
    customer_billing_address text,
    customer_shipping_address text,
    CONSTRAINT quotations_approval_status_check CHECK (((approval_status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text]))),
    CONSTRAINT quotations_status_check CHECK (((status)::text = ANY (ARRAY[('draft'::character varying)::text, ('sent'::character varying)::text, ('accepted'::character varying)::text, ('rejected'::character varying)::text])))
);


--
-- Name: quotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quotations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quotations_id_seq OWNED BY public.quotations.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    is_system boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: sale_return_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sale_return_items (
    id integer NOT NULL,
    return_id integer NOT NULL,
    product_id integer,
    description text NOT NULL,
    quantity numeric(15,3) NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL,
    gst_rate numeric(5,2) DEFAULT 0 NOT NULL,
    total numeric(15,2) NOT NULL
);


--
-- Name: sale_return_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sale_return_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sale_return_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sale_return_items_id_seq OWNED BY public.sale_return_items.id;


--
-- Name: sale_return_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sale_return_payments (
    id integer NOT NULL,
    return_id integer NOT NULL,
    amount numeric(15,2) NOT NULL,
    payment_date date DEFAULT CURRENT_DATE NOT NULL,
    method character varying(50) DEFAULT 'bank_transfer'::character varying NOT NULL,
    reference character varying(200),
    notes text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: sale_return_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sale_return_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sale_return_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sale_return_payments_id_seq OWNED BY public.sale_return_payments.id;


--
-- Name: sale_returns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sale_returns (
    id integer NOT NULL,
    return_number character varying(50) NOT NULL,
    customer_id integer NOT NULL,
    reference_no character varying(100),
    return_date date DEFAULT CURRENT_DATE NOT NULL,
    state_of_supply character varying(50),
    exchange_rate numeric(10,4) DEFAULT 1 NOT NULL,
    notes text,
    subtotal numeric(15,2) DEFAULT 0 NOT NULL,
    cgst numeric(15,2) DEFAULT 0 NOT NULL,
    sgst numeric(15,2) DEFAULT 0 NOT NULL,
    igst numeric(15,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(15,2) DEFAULT 0 NOT NULL,
    round_off numeric(10,2) DEFAULT 0 NOT NULL,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    paid_amount numeric(15,2) DEFAULT 0 NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer
);


--
-- Name: sale_returns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sale_returns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sale_returns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sale_returns_id_seq OWNED BY public.sale_returns.id;


--
-- Name: sales_order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer,
    description text NOT NULL,
    quantity numeric(15,3) NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    gst_rate numeric(5,2) DEFAULT 0 NOT NULL,
    total numeric(15,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL,
    cgst numeric(15,2) DEFAULT 0 NOT NULL,
    sgst numeric(15,2) DEFAULT 0 NOT NULL,
    igst numeric(15,2) DEFAULT 0 NOT NULL
);


--
-- Name: sales_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_order_items_id_seq OWNED BY public.sales_order_items.id;


--
-- Name: sales_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_orders (
    id integer NOT NULL,
    order_number character varying(50) NOT NULL,
    customer_id integer NOT NULL,
    quotation_id integer,
    status character varying(30) DEFAULT 'pending'::character varying NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    notes text,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    due_date date,
    exchange_rate numeric(10,4) DEFAULT 1 NOT NULL,
    state_of_supply character varying(50),
    discount_amount numeric(15,2) DEFAULT 0 NOT NULL,
    round_off numeric(10,2) DEFAULT 0 NOT NULL,
    gst_type character varying(20) DEFAULT 'intra_state'::character varying NOT NULL,
    tax_type character varying(20) DEFAULT 'exclusive'::character varying NOT NULL,
    is_interstate boolean DEFAULT false NOT NULL,
    subtotal numeric(15,2) DEFAULT 0 NOT NULL,
    cgst numeric(15,2) DEFAULT 0 NOT NULL,
    sgst numeric(15,2) DEFAULT 0 NOT NULL,
    igst numeric(15,2) DEFAULT 0 NOT NULL,
    approval_status character varying(20) DEFAULT 'approved'::character varying NOT NULL,
    approved_by integer,
    approved_at timestamp with time zone,
    tenant_id integer,
    CONSTRAINT sales_orders_approval_status_check CHECK (((approval_status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text]))),
    CONSTRAINT sales_orders_status_check CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('processing'::character varying)::text, ('shipped'::character varying)::text, ('delivered'::character varying)::text, ('cancelled'::character varying)::text])))
);


--
-- Name: sales_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sales_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_orders_id_seq OWNED BY public.sales_orders.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schema_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schema_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schema_migrations_id_seq OWNED BY public.schema_migrations.id;


--
-- Name: stock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock (
    id integer NOT NULL,
    product_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    quantity numeric(15,3) DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: stock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_id_seq OWNED BY public.stock.id;


--
-- Name: stock_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_movements (
    id integer NOT NULL,
    product_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    type character varying(20) NOT NULL,
    quantity numeric(15,3) NOT NULL,
    reference character varying(200),
    note text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL,
    CONSTRAINT stock_movements_type_check CHECK (((type)::text = ANY (ARRAY[('in'::character varying)::text, ('out'::character varying)::text, ('transfer'::character varying)::text, ('adjustment'::character varying)::text])))
);


--
-- Name: stock_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_movements_id_seq OWNED BY public.stock_movements.id;


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    slug character varying(120) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenants_id_seq OWNED BY public.tenants.id;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_permissions_id_seq OWNED BY public.user_permissions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    email character varying(255) NOT NULL,
    password text NOT NULL,
    role character varying(50) DEFAULT 'Agent'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    role_id integer NOT NULL,
    avatar_url character varying(500),
    zone_id integer,
    sales_manager_id integer,
    tenant_id integer DEFAULT 1 NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vendors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendors (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    email character varying(255),
    phone character varying(20),
    gstin character varying(15),
    address text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vendors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vendors_id_seq OWNED BY public.vendors.id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warehouses (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    location text,
    is_active boolean DEFAULT true NOT NULL,
    tenant_id integer NOT NULL
);


--
-- Name: warehouses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.warehouses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: warehouses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.warehouses_id_seq OWNED BY public.warehouses.id;


--
-- Name: work_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_orders (
    id integer NOT NULL,
    wo_number character varying(50) NOT NULL,
    product_id integer NOT NULL,
    bom_id integer,
    quantity numeric(15,3) NOT NULL,
    status character varying(30) DEFAULT 'planned'::character varying NOT NULL,
    planned_start date,
    planned_end date,
    actual_start date,
    actual_end date,
    notes text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT work_orders_status_check CHECK (((status)::text = ANY (ARRAY[('planned'::character varying)::text, ('in_progress'::character varying)::text, ('completed'::character varying)::text, ('cancelled'::character varying)::text])))
);


--
-- Name: work_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_orders_id_seq OWNED BY public.work_orders.id;


--
-- Name: zones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.zones (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    code character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: zones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.zones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.zones_id_seq OWNED BY public.zones.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: attendance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: bom id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bom ALTER COLUMN id SET DEFAULT nextval('public.bom_id_seq'::regclass);


--
-- Name: bom_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bom_items ALTER COLUMN id SET DEFAULT nextval('public.bom_items_id_seq'::regclass);


--
-- Name: brands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands ALTER COLUMN id SET DEFAULT nextval('public.brands_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: comm_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_logs ALTER COLUMN id SET DEFAULT nextval('public.comm_logs_id_seq'::regclass);


--
-- Name: comm_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_templates ALTER COLUMN id SET DEFAULT nextval('public.comm_templates_id_seq'::regclass);


--
-- Name: company_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_settings ALTER COLUMN id SET DEFAULT nextval('public.company_settings_id_seq'::regclass);


--
-- Name: crm_platforms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_platforms ALTER COLUMN id SET DEFAULT nextval('public.crm_platforms_id_seq'::regclass);


--
-- Name: crm_priorities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_priorities ALTER COLUMN id SET DEFAULT nextval('public.crm_priorities_id_seq'::regclass);


--
-- Name: crm_segments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_segments ALTER COLUMN id SET DEFAULT nextval('public.crm_segments_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Name: grn id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn ALTER COLUMN id SET DEFAULT nextval('public.grn_id_seq'::regclass);


--
-- Name: grn_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items ALTER COLUMN id SET DEFAULT nextval('public.grn_items_id_seq'::regclass);


--
-- Name: invoice_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items ALTER COLUMN id SET DEFAULT nextval('public.invoice_items_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: journal_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries ALTER COLUMN id SET DEFAULT nextval('public.journal_entries_id_seq'::regclass);


--
-- Name: journal_lines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_lines ALTER COLUMN id SET DEFAULT nextval('public.journal_lines_id_seq'::regclass);


--
-- Name: lead_activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_activities ALTER COLUMN id SET DEFAULT nextval('public.lead_activities_id_seq'::regclass);


--
-- Name: lead_followups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_followups ALTER COLUMN id SET DEFAULT nextval('public.lead_followups_id_seq'::regclass);


--
-- Name: lead_form_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_form_submissions ALTER COLUMN id SET DEFAULT nextval('public.lead_form_submissions_id_seq'::regclass);


--
-- Name: lead_forms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_forms ALTER COLUMN id SET DEFAULT nextval('public.lead_forms_id_seq'::regclass);


--
-- Name: lead_platform_facebook_leads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_leads ALTER COLUMN id SET DEFAULT nextval('public.lead_platform_facebook_leads_id_seq'::regclass);


--
-- Name: lead_platform_facebook_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_pages ALTER COLUMN id SET DEFAULT nextval('public.lead_platform_facebook_pages_id_seq'::regclass);


--
-- Name: lead_platform_google_sheets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_google_sheets ALTER COLUMN id SET DEFAULT nextval('public.lead_platform_google_sheets_id_seq'::regclass);


--
-- Name: lead_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_sources ALTER COLUMN id SET DEFAULT nextval('public.lead_sources_id_seq'::regclass);


--
-- Name: lead_stages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_stages ALTER COLUMN id SET DEFAULT nextval('public.lead_stages_id_seq'::regclass);


--
-- Name: leads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads ALTER COLUMN id SET DEFAULT nextval('public.leads_id_seq'::regclass);


--
-- Name: module_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_settings ALTER COLUMN id SET DEFAULT nextval('public.module_settings_id_seq'::regclass);


--
-- Name: notification_push_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_push_tokens ALTER COLUMN id SET DEFAULT nextval('public.notification_push_tokens_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: payroll id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payroll ALTER COLUMN id SET DEFAULT nextval('public.payroll_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: proposal_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposal_items ALTER COLUMN id SET DEFAULT nextval('public.proposal_items_id_seq'::regclass);


--
-- Name: proposals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals ALTER COLUMN id SET DEFAULT nextval('public.proposals_id_seq'::regclass);


--
-- Name: purchase_invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_invoices ALTER COLUMN id SET DEFAULT nextval('public.purchase_invoices_id_seq'::regclass);


--
-- Name: purchase_order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items ALTER COLUMN id SET DEFAULT nextval('public.purchase_order_items_id_seq'::regclass);


--
-- Name: purchase_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders ALTER COLUMN id SET DEFAULT nextval('public.purchase_orders_id_seq'::regclass);


--
-- Name: quotation_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items ALTER COLUMN id SET DEFAULT nextval('public.quotation_items_id_seq'::regclass);


--
-- Name: quotations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations ALTER COLUMN id SET DEFAULT nextval('public.quotations_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: sale_return_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_items ALTER COLUMN id SET DEFAULT nextval('public.sale_return_items_id_seq'::regclass);


--
-- Name: sale_return_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_payments ALTER COLUMN id SET DEFAULT nextval('public.sale_return_payments_id_seq'::regclass);


--
-- Name: sale_returns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_returns ALTER COLUMN id SET DEFAULT nextval('public.sale_returns_id_seq'::regclass);


--
-- Name: sales_order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items ALTER COLUMN id SET DEFAULT nextval('public.sales_order_items_id_seq'::regclass);


--
-- Name: sales_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders ALTER COLUMN id SET DEFAULT nextval('public.sales_orders_id_seq'::regclass);


--
-- Name: schema_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations ALTER COLUMN id SET DEFAULT nextval('public.schema_migrations_id_seq'::regclass);


--
-- Name: stock id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock ALTER COLUMN id SET DEFAULT nextval('public.stock_id_seq'::regclass);


--
-- Name: stock_movements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements ALTER COLUMN id SET DEFAULT nextval('public.stock_movements_id_seq'::regclass);


--
-- Name: tenants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants ALTER COLUMN id SET DEFAULT nextval('public.tenants_id_seq'::regclass);


--
-- Name: user_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions ALTER COLUMN id SET DEFAULT nextval('public.user_permissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vendors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors ALTER COLUMN id SET DEFAULT nextval('public.vendors_id_seq'::regclass);


--
-- Name: warehouses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN id SET DEFAULT nextval('public.warehouses_id_seq'::regclass);


--
-- Name: work_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders ALTER COLUMN id SET DEFAULT nextval('public.work_orders_id_seq'::regclass);


--
-- Name: zones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones ALTER COLUMN id SET DEFAULT nextval('public.zones_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accounts (id, code, name, type, parent_id, is_active, tenant_id) FROM stdin;
1	1000	Cash and Bank	asset	\N	t	1
2	1100	Accounts Receivable	asset	\N	t	1
3	2000	Accounts Payable	liability	\N	t	1
4	4000	Sales Revenue	income	\N	t	1
5	5000	Cost of Goods Sold	expense	\N	t	1
6	6000	Operating Expenses	expense	\N	t	1
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attendance (id, date, check_in, check_out, status, notes, user_id, tenant_id) FROM stdin;
9	2026-04-13	07:23:42	\N	present	\N	14	1
10	2026-04-13	07:24:43	10:02:51	present	\N	8	1
11	2026-04-13	10:06:31	15:46:26	present	\N	15	1
12	2026-04-13	16:55:10	\N	present	\N	16	1
13	2026-04-14	13:31:03	\N	present	\N	8	1
14	2026-04-14	13:35:56	\N	present	\N	16	1
15	2026-04-14	13:43:59	\N	present	\N	15	1
16	2026-04-15	09:58:04	17:03:04	present	\N	16	1
17	2026-04-16	10:36:26	20:13:06	present	\N	16	1
18	2026-04-16	20:16:28	\N	present	\N	15	1
19	2026-04-17	09:39:43	19:13:16	present	\N	15	1
21	2026-04-18	10:43:58	17:34:16	present	\N	15	1
20	2026-04-18	10:38:36	20:25:03	present	\N	16	1
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, user_id, action, module, record_id, details, ip_address, created_at) FROM stdin;
146	5	create_role	users	14	{"name": "Sales Manager"}	\N	2026-04-13 07:27:43.237631+00
147	5	create_user	users	15	{"name": "sales manager", "role": "Sales Executive", "email": "demo.admin@example.com"}	\N	2026-04-13 07:28:35.129279+00
148	5	set_role_permissions	users	14	{"count": 72}	\N	2026-04-13 07:28:43.214372+00
149	5	update_user	users	15	{"fields": ["name", "email", "role", "password"]}	\N	2026-04-13 07:29:26.265626+00
150	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-13 07:32:59.739216+00
151	5	login	auth	\N	\N	\N	2026-04-13 08:01:04.364797+00
152	5	update_company_settings	settings	\N	\N	\N	2026-04-13 08:10:22.11628+00
153	5	update_company_settings	settings	\N	\N	\N	2026-04-13 08:10:29.936138+00
154	5	update_company_settings	settings	\N	\N	\N	2026-04-13 08:10:33.792806+00
155	5	update_user	users	8	{"fields": ["name", "email", "role", "zone_id", "sales_manager_id"]}	\N	2026-04-13 08:15:14.822757+00
156	5	update_user	users	14	{"fields": ["sales_manager_id"]}	\N	2026-04-13 08:15:54.751724+00
157	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-13 08:16:01.429103+00
158	15	login	auth	\N	\N	\N	2026-04-13 08:25:25.775425+00
159	5	login	auth	\N	\N	\N	2026-04-13 08:26:11.701442+00
160	5	login	auth	\N	\N	\N	2026-04-13 08:29:10.667521+00
161	5	login	auth	\N	\N	\N	2026-04-13 08:30:32.362133+00
162	5	set_role_permissions	users	1	{"count": 52}	\N	2026-04-13 08:33:48.415585+00
163	5	login	auth	\N	\N	\N	2026-04-13 09:28:58.826163+00
164	5	update_avatar	auth	\N	\N	\N	2026-04-13 09:41:13.290773+00
165	15	login	auth	\N	\N	\N	2026-04-13 09:42:35.478715+00
166	5	update_module_settings	settings	\N	{"module": "production", "is_enabled": true, "allowed_roles": ["Super Admin", "Admin", "Sales Executive", "HR"]}	\N	2026-04-13 09:45:19.366974+00
167	15	login	auth	\N	\N	\N	2026-04-13 09:46:20.848153+00
168	5	set_role_permissions	users	14	{"count": 80}	\N	2026-04-13 09:50:00.993106+00
169	15	login	auth	\N	\N	\N	2026-04-13 09:52:22.761369+00
170	5	login	auth	\N	\N	\N	2026-04-13 09:52:42.246161+00
171	5	update_module_settings	settings	\N	{"module": "crm", "allowed_roles": ["Super Admin", "Admin", "Sales Executive", "Manager", "Agent", "Accountant", "Sales Manager"]}	\N	2026-04-13 09:52:59.366616+00
172	5	update_module_settings	settings	\N	{"module": "crm", "allowed_roles": ["Super Admin", "Admin", "Sales Executive", "Manager", "Agent", "Accountant", "Sales Manager"]}	\N	2026-04-13 09:53:02.196204+00
173	5	update_module_settings	settings	\N	{"module": "sales", "allowed_roles": ["Super Admin", "Admin", "Sales Executive", "Sales Manager"]}	\N	2026-04-13 09:53:04.791117+00
174	5	set_user_permissions	users	15	{"count": 80}	\N	2026-04-13 09:53:07.162879+00
175	5	update_module_settings	settings	\N	{"module": "inventory", "allowed_roles": ["Super Admin", "Admin", "Sales Executive", "HR", "Sales Manager"]}	\N	2026-04-13 09:53:08.281086+00
176	5	update_module_settings	settings	\N	{"module": "users", "allowed_roles": ["Super Admin", "Admin", "HR", "Sales Manager"]}	\N	2026-04-13 09:53:23.434414+00
177	15	login	auth	\N	\N	\N	2026-04-13 09:54:22.480087+00
178	8	login	auth	\N	\N	\N	2026-04-13 10:02:35.632364+00
179	15	login	auth	\N	\N	\N	2026-04-13 10:25:08.181069+00
180	8	login	auth	\N	\N	\N	2026-04-13 10:26:02.200945+00
181	15	login	auth	\N	\N	\N	2026-04-13 10:27:16.321124+00
182	8	login	auth	\N	\N	\N	2026-04-13 10:32:04.946497+00
183	8	login	auth	\N	\N	\N	2026-04-13 10:53:22.424892+00
184	5	login	auth	\N	\N	\N	2026-04-13 10:54:49.391251+00
185	5	create_user	users	16	{"name": "Gokul", "role": "Sales Executive", "email": "igloogokul2010@gmail.com"}	\N	2026-04-13 10:56:35.76366+00
186	5	update_avatar	auth	\N	\N	\N	2026-04-13 11:03:22.06998+00
187	15	login	auth	\N	\N	\N	2026-04-13 11:09:13.904569+00
188	5	update_avatar	auth	\N	\N	\N	2026-04-13 11:14:23.310896+00
189	15	login	auth	\N	\N	\N	2026-04-13 11:23:15.121917+00
190	5	update_user	users	16	{"fields": ["name", "email", "role", "zone_id", "password", "sales_manager_id"]}	\N	2026-04-13 11:24:54.06886+00
191	16	login	auth	\N	\N	\N	2026-04-13 11:24:59.504069+00
192	15	login	auth	\N	\N	\N	2026-04-13 11:42:29.903881+00
193	8	login	auth	\N	\N	\N	2026-04-13 11:44:23.021338+00
194	15	login	auth	\N	\N	\N	2026-04-13 11:46:26.269942+00
195	15	update_avatar	auth	\N	\N	\N	2026-04-13 11:48:18.768819+00
196	8	login	auth	\N	\N	\N	2026-04-13 11:49:14.289235+00
197	8	update_avatar	auth	\N	\N	\N	2026-04-13 11:49:34.988967+00
198	5	login	auth	\N	\N	\N	2026-04-13 12:22:55.393618+00
199	5	update_avatar	auth	\N	\N	\N	2026-04-13 12:26:05.21234+00
200	5	update_company_settings	settings	\N	\N	\N	2026-04-13 12:26:21.910541+00
201	5	update_company_settings	settings	\N	\N	\N	2026-04-13 12:26:26.485774+00
202	5	update_company_settings	settings	\N	\N	\N	2026-04-13 12:26:32.792326+00
203	5	update_company_settings	settings	\N	\N	\N	2026-04-13 13:03:27.597469+00
204	5	update_company_settings	settings	\N	\N	\N	2026-04-13 13:03:31.381739+00
205	15	update_avatar	auth	\N	\N	\N	2026-04-14 07:21:08.87648+00
206	5	update_avatar	auth	\N	\N	\N	2026-04-14 07:23:41.739468+00
207	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-14 07:24:45.784027+00
208	15	login	auth	\N	\N	\N	2026-04-14 07:31:18.054267+00
209	15	update_avatar	auth	\N	\N	\N	2026-04-14 07:32:17.463984+00
210	5	login	auth	\N	\N	\N	2026-04-14 07:58:24.908881+00
211	8	login	auth	\N	\N	\N	2026-04-14 08:00:53.099236+00
212	16	login	auth	\N	\N	\N	2026-04-14 08:05:15.997289+00
213	15	login	auth	\N	\N	\N	2026-04-14 08:05:31.536225+00
214	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-14 08:12:27.297353+00
215	15	login	auth	\N	\N	\N	2026-04-14 08:13:08.190413+00
216	15	update_avatar	auth	\N	\N	\N	2026-04-14 08:13:30.327467+00
217	15	clear_avatar	auth	\N	\N	\N	2026-04-14 08:13:35.886485+00
218	15	update_avatar	auth	\N	\N	\N	2026-04-14 08:13:43.349411+00
219	5	update_company_settings	settings	\N	\N	\N	2026-04-14 08:17:30.995986+00
220	5	update_company_settings	settings	\N	\N	\N	2026-04-14 08:17:36.165776+00
221	5	update_company_settings	settings	\N	\N	\N	2026-04-14 08:17:43.278547+00
222	5	update_avatar	auth	\N	\N	\N	2026-04-14 08:18:14.126459+00
223	15	login	auth	\N	\N	\N	2026-04-14 08:22:41.889968+00
224	15	login	auth	\N	\N	\N	2026-04-14 08:23:14.403309+00
225	5	login	auth	\N	\N	\N	2026-04-14 08:28:12.724386+00
226	15	login	auth	\N	\N	\N	2026-04-14 08:28:51.357158+00
227	15	login	auth	\N	\N	\N	2026-04-14 08:32:08.092325+00
228	5	update_avatar	auth	\N	\N	\N	2026-04-14 08:56:38.858533+00
229	5	update_avatar	auth	\N	\N	\N	2026-04-14 09:00:06.298292+00
230	5	update_avatar	auth	\N	\N	\N	2026-04-14 09:00:15.402855+00
231	5	login	auth	\N	\N	\N	2026-04-14 09:13:55.355378+00
232	5	update_company_settings	settings	\N	\N	\N	2026-04-14 09:18:05.746133+00
233	5	update_company_settings	settings	\N	\N	\N	2026-04-14 09:55:04.289371+00
234	5	update_company_settings	settings	\N	\N	\N	2026-04-14 10:12:02.349622+00
235	5	update_company_settings	settings	\N	\N	\N	2026-04-14 10:16:23.246964+00
236	5	update_company_settings	settings	\N	\N	\N	2026-04-14 10:23:28.404395+00
237	5	update_company_settings	settings	\N	\N	\N	2026-04-14 10:24:04.555779+00
238	5	update_company_settings	settings	\N	\N	\N	2026-04-14 10:27:30.849509+00
239	16	login	auth	\N	\N	\N	2026-04-14 10:45:40.83338+00
240	5	update_company_settings	settings	\N	\N	\N	2026-04-14 11:29:54.896921+00
241	5	update_company_settings	settings	\N	\N	\N	2026-04-14 11:29:57.970316+00
242	5	update_avatar	auth	\N	\N	\N	2026-04-14 11:30:18.806583+00
243	5	update_company_settings	settings	\N	\N	\N	2026-04-14 11:40:27.807567+00
244	5	update_company_settings	settings	\N	\N	\N	2026-04-14 11:41:18.712986+00
245	5	update_company_settings	settings	\N	\N	\N	2026-04-14 11:42:02.585776+00
246	5	update_company_settings	settings	\N	\N	\N	2026-04-14 11:43:20.453736+00
247	5	update_company_settings	settings	\N	\N	\N	2026-04-14 12:01:40.114731+00
248	5	update_company_settings	settings	\N	\N	\N	2026-04-14 12:08:06.999056+00
249	5	update_company_settings	settings	\N	\N	\N	2026-04-14 12:57:40.616432+00
250	15	login	auth	\N	\N	\N	2026-04-14 14:24:49.789249+00
251	15	login	auth	\N	\N	\N	2026-04-14 14:36:18.208397+00
252	15	login	auth	\N	\N	\N	2026-04-14 15:06:21.198575+00
253	15	login	auth	\N	\N	\N	2026-04-14 16:22:25.303571+00
254	15	login	auth	\N	\N	\N	2026-04-14 16:58:00.31475+00
255	5	update_company_settings	settings	\N	\N	\N	2026-04-14 17:00:18.37776+00
256	5	update_company_settings	settings	\N	\N	\N	2026-04-14 17:00:23.209108+00
257	15	update_avatar	auth	\N	\N	\N	2026-04-14 18:15:58.795626+00
258	15	login	auth	\N	\N	\N	2026-04-14 18:37:06.834298+00
259	5	login	auth	\N	\N	\N	2026-04-14 18:39:26.523602+00
260	5	update_company_settings	settings	\N	\N	\N	2026-04-14 18:39:46.948934+00
261	16	login	auth	\N	\N	\N	2026-04-15 02:09:39.757409+00
262	15	login	auth	\N	\N	\N	2026-04-15 05:07:17.519545+00
263	5	login	auth	\N	\N	\N	2026-04-15 05:11:31.785154+00
264	5	update_avatar	auth	\N	\N	\N	2026-04-15 05:17:40.328277+00
265	5	update_avatar	auth	\N	\N	\N	2026-04-15 05:17:48.65603+00
266	5	login	auth	\N	\N	\N	2026-04-15 06:14:18.452369+00
267	5	login	auth	\N	\N	\N	2026-04-15 06:25:40.017645+00
268	5	login	auth	\N	\N	\N	2026-04-15 06:35:34.308514+00
269	5	update_user	users	5	{"fields": ["name", "email", "role", "zone_id"]}	\N	2026-04-15 06:36:48.124535+00
270	5	update_user	users	5	{"fields": ["name", "email", "role", "zone_id"]}	\N	2026-04-15 06:38:26.19376+00
271	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id"]}	\N	2026-04-15 06:39:18.783823+00
272	5	update_user	users	16	{"fields": ["name", "email", "role", "zone_id", "sales_manager_id"]}	\N	2026-04-15 06:39:32.227494+00
273	5	update_user	users	14	{"fields": ["name", "email", "role", "zone_id", "sales_manager_id"]}	\N	2026-04-15 06:40:17.337407+00
274	5	update_company_settings	settings	\N	\N	\N	2026-04-15 07:00:30.183359+00
275	5	update_company_settings	settings	\N	\N	\N	2026-04-15 07:01:28.922311+00
276	5	update_user	users	14	{"fields": ["name", "email", "role", "zone_id", "sales_manager_id"]}	\N	2026-04-15 07:02:04.226605+00
277	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id"]}	\N	2026-04-15 07:02:30.757496+00
278	5	update_company_settings	settings	\N	\N	\N	2026-04-15 07:05:24.754156+00
279	5	update_company_settings	settings	\N	\N	\N	2026-04-15 07:05:35.472254+00
280	5	update_company_settings	settings	\N	\N	\N	2026-04-15 07:05:58.152204+00
281	5	update_company_settings	settings	\N	\N	\N	2026-04-15 07:07:36.411231+00
282	5	disable_user	users	8	\N	\N	2026-04-15 07:09:33.31091+00
283	5	update_user	users	5	{"fields": ["name", "email", "role", "zone_id"]}	\N	2026-04-15 07:10:32.867264+00
284	5	login	auth	\N	\N	\N	2026-04-15 07:15:22.768669+00
285	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-15 07:16:39.283896+00
286	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-15 07:17:12.340365+00
287	5	login	auth	\N	\N	\N	2026-04-15 07:17:40.910822+00
288	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-15 07:19:06.763828+00
289	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id"]}	\N	2026-04-15 07:20:08.189089+00
290	15	login	auth	\N	\N	\N	2026-04-15 07:20:12.309007+00
291	15	login	auth	\N	\N	\N	2026-04-15 07:20:14.527955+00
292	5	update_company_settings	settings	\N	\N	\N	2026-04-15 07:31:41.142062+00
293	15	login	auth	\N	\N	\N	2026-04-15 08:46:30.50472+00
294	5	login	auth	\N	\N	\N	2026-04-15 09:11:45.765516+00
295	16	login	auth	\N	\N	\N	2026-04-15 09:36:57.389022+00
296	5	update_company_settings	settings	\N	\N	\N	2026-04-15 10:32:16.657266+00
297	5	update_company_settings	settings	\N	\N	\N	2026-04-15 11:05:38.642232+00
298	5	update_company_settings	settings	\N	\N	\N	2026-04-15 11:05:51.886185+00
299	15	login	auth	\N	\N	\N	2026-04-15 11:52:58.678889+00
300	15	login	auth	\N	\N	\N	2026-04-15 12:27:23.402691+00
301	15	login	auth	\N	\N	\N	2026-04-15 12:29:11.83035+00
302	5	login	auth	\N	\N	\N	2026-04-15 12:36:54.449307+00
303	15	update_avatar	auth	\N	\N	\N	2026-04-15 13:52:07.197066+00
304	15	login	auth	\N	\N	\N	2026-04-15 14:03:35.399355+00
305	15	login	auth	\N	\N	\N	2026-04-15 17:14:25.014916+00
306	1	login	auth	\N	\N	\N	2026-04-15 17:14:43.681823+00
307	15	login	auth	\N	\N	\N	2026-04-16 01:37:36.127013+00
308	15	update_avatar	auth	\N	\N	\N	2026-04-16 02:33:15.478776+00
309	15	login	auth	\N	\N	\N	2026-04-16 04:35:40.298203+00
310	15	login	auth	\N	\N	\N	2026-04-16 04:44:57.460685+00
311	15	login	auth	\N	\N	\N	2026-04-16 05:15:50.103856+00
312	15	login	auth	\N	\N	\N	2026-04-16 05:23:58.485778+00
313	5	login	auth	\N	\N	\N	2026-04-16 05:24:59.300179+00
314	5	update_company_settings	settings	\N	\N	\N	2026-04-16 05:25:40.945712+00
315	15	login	auth	\N	\N	\N	2026-04-16 05:35:11.523669+00
316	15	login	auth	\N	\N	\N	2026-04-16 05:39:16.356731+00
317	5	login	auth	\N	\N	\N	2026-04-16 05:40:00.008066+00
318	5	update_company_settings	settings	\N	\N	\N	2026-04-16 05:45:54.808446+00
319	5	login	auth	\N	\N	\N	2026-04-16 06:05:27.344606+00
320	5	set_role_permissions	users	14	{"count": 80}	\N	2026-04-16 06:06:53.88054+00
321	15	login	auth	\N	\N	\N	2026-04-16 06:07:53.345859+00
322	15	update_avatar	auth	\N	\N	\N	2026-04-16 06:09:48.64001+00
323	15	login	auth	\N	\N	\N	2026-04-16 06:19:15.98624+00
324	5	login	auth	\N	\N	\N	2026-04-16 06:41:02.837081+00
325	5	update_company_settings	settings	\N	\N	\N	2026-04-16 06:49:08.264687+00
326	5	update_company_settings	settings	\N	\N	\N	2026-04-16 06:49:10.732893+00
327	5	update_company_settings	settings	\N	\N	\N	2026-04-16 06:49:11.757913+00
328	5	update_company_settings	settings	\N	\N	\N	2026-04-16 06:49:12.789809+00
329	5	update_company_settings	settings	\N	\N	\N	2026-04-16 06:49:13.818228+00
330	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-16 06:58:40.613874+00
331	5	create_zone	users	5	\N	\N	2026-04-16 07:00:06.217751+00
332	5	update_user	users	15	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-16 07:00:48.956312+00
333	5	create_zone	users	6	\N	\N	2026-04-16 07:02:12.264085+00
334	5	update_zone	users	5	\N	\N	2026-04-16 07:02:23.026582+00
335	5	update_zone	users	3	\N	\N	2026-04-16 07:03:24.304987+00
336	5	update_user	users	16	{"fields": ["name", "email", "role", "zone_id", "sales_manager_id"]}	\N	2026-04-16 07:03:53.126257+00
337	5	update_user	users	14	{"fields": ["name", "email", "role", "zone_id", "sales_manager_id"]}	\N	2026-04-16 07:04:06.51361+00
338	5	update_zone	users	4	\N	\N	2026-04-16 07:05:03.480802+00
339	5	update_user	users	5	{"fields": ["name", "email", "role", "zone_id", "password"]}	\N	2026-04-16 07:05:19.746746+00
340	5	update_company_settings	settings	\N	\N	\N	2026-04-16 07:12:08.606577+00
341	5	update_company_settings	settings	\N	\N	\N	2026-04-16 07:27:48.873061+00
342	5	update_company_settings	settings	\N	\N	\N	2026-04-16 07:27:49.976106+00
343	5	update_company_settings	settings	\N	\N	\N	2026-04-16 07:27:51.274966+00
344	5	update_company_settings	settings	\N	\N	\N	2026-04-16 07:27:51.509426+00
345	5	update_company_settings	settings	\N	\N	\N	2026-04-16 07:30:04.239092+00
346	5	update_module_settings	settings	\N	{"module": "settings", "allowed_roles": ["Super Admin", "Admin", "HR", "Sales Manager"]}	\N	2026-04-16 07:53:18.735479+00
347	5	login	auth	\N	\N	\N	2026-04-16 09:55:11.171393+00
348	15	login	auth	\N	\N	\N	2026-04-16 12:56:29.729576+00
349	5	login	auth	\N	\N	\N	2026-04-16 13:20:06.191938+00
350	5	update_company_settings	settings	\N	\N	\N	2026-04-16 13:20:19.91597+00
351	15	login	auth	\N	\N	\N	2026-04-16 13:38:56.320376+00
352	1	login	auth	\N	\N	\N	2026-04-16 13:41:58.129383+00
353	15	login	auth	\N	\N	\N	2026-04-16 13:52:48.639652+00
354	15	update_avatar	auth	\N	\N	\N	2026-04-16 13:57:08.542411+00
355	1	update_company_settings	settings	\N	\N	\N	2026-04-16 14:25:12.26669+00
356	1	update_company_settings	settings	\N	\N	\N	2026-04-16 14:39:32.473771+00
357	15	login	auth	\N	\N	\N	2026-04-16 14:49:54.297865+00
358	15	login	auth	\N	\N	\N	2026-04-17 02:27:43.47082+00
359	15	login	auth	\N	\N	\N	2026-04-17 02:29:27.016412+00
360	15	login	auth	\N	\N	\N	2026-04-17 02:36:44.111605+00
361	15	update_avatar	auth	\N	\N	\N	2026-04-17 02:48:02.997013+00
362	5	update_company_settings	settings	\N	\N	\N	2026-04-17 04:56:43.690107+00
363	5	update_company_settings	settings	\N	\N	\N	2026-04-17 04:56:47.783028+00
364	1	update_company_settings	settings	\N	\N	\N	2026-04-17 05:01:54.530429+00
365	1	update_company_settings	settings	\N	\N	\N	2026-04-17 05:16:05.534275+00
366	5	login	auth	\N	\N	\N	2026-04-17 06:19:33.519435+00
367	1	login	auth	\N	\N	\N	2026-04-17 06:55:27.267469+00
368	5	login	auth	\N	\N	\N	2026-04-17 07:00:57.253499+00
369	15	login	auth	\N	\N	\N	2026-04-17 07:06:25.904781+00
370	5	login	auth	\N	\N	\N	2026-04-17 07:13:11.123141+00
371	5	login	auth	\N	\N	\N	2026-04-17 07:18:24.620033+00
372	1	login	auth	\N	\N	\N	2026-04-17 07:26:38.143325+00
373	5	login	auth	\N	\N	\N	2026-04-17 07:28:05.794137+00
374	5	login	auth	\N	\N	\N	2026-04-17 07:33:54.554238+00
375	5	login	auth	\N	\N	\N	2026-04-17 07:34:13.46279+00
376	5	login	auth	\N	\N	\N	2026-04-17 07:37:27.993489+00
377	5	login	auth	\N	\N	\N	2026-04-17 07:39:31.349997+00
378	5	login	auth	\N	\N	\N	2026-04-17 07:40:11.985772+00
379	5	login	auth	\N	\N	\N	2026-04-17 07:42:03.181901+00
380	15	login	auth	\N	\N	\N	2026-04-17 07:43:02.864978+00
381	5	login	auth	\N	\N	\N	2026-04-17 07:44:23.017818+00
382	15	login	auth	\N	\N	\N	2026-04-17 07:48:42.475946+00
383	15	login	auth	\N	\N	\N	2026-04-17 08:01:09.734182+00
384	15	login	auth	\N	\N	\N	2026-04-17 08:03:36.795833+00
385	5	login	auth	\N	\N	\N	2026-04-17 09:11:51.008917+00
386	15	login	auth	\N	\N	\N	2026-04-17 10:02:09.389671+00
387	15	login	auth	\N	\N	\N	2026-04-17 10:11:59.22786+00
388	5	login	auth	\N	\N	\N	2026-04-17 10:15:58.290108+00
389	5	login	auth	\N	\N	\N	2026-04-17 10:20:51.804499+00
390	15	login	auth	\N	\N	\N	2026-04-17 10:23:25.350349+00
391	5	update_company_settings	settings	\N	\N	\N	2026-04-17 10:26:22.897952+00
392	5	login	auth	\N	\N	\N	2026-04-17 10:26:40.128473+00
393	5	login	auth	\N	\N	\N	2026-04-17 10:31:21.753006+00
394	5	login	auth	\N	\N	\N	2026-04-17 11:17:33.196537+00
395	5	update_company_settings	settings	\N	\N	\N	2026-04-17 11:55:14.907735+00
396	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:12:29.870921+00
397	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:17:08.148751+00
398	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:22:51.128999+00
399	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:29:23.56163+00
400	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:30:09.122636+00
401	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:31:40.336229+00
402	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:44:50.513778+00
403	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:45:16.795165+00
404	5	update_company_settings	settings	\N	\N	\N	2026-04-17 12:47:17.982002+00
405	5	login	auth	\N	\N	\N	2026-04-17 13:33:27.582341+00
406	5	update_avatar	auth	\N	\N	\N	2026-04-17 13:33:54.712679+00
407	5	login	auth	\N	\N	\N	2026-04-18 02:13:33.524591+00
408	5	login	auth	\N	\N	\N	2026-04-18 02:21:24.794565+00
409	5	login	auth	\N	\N	\N	2026-04-18 04:37:37.278049+00
410	5	login	auth	\N	\N	\N	2026-04-18 04:43:54.035179+00
411	5	update_company_settings	settings	\N	\N	\N	2026-04-18 04:44:41.78178+00
412	5	login	auth	\N	\N	\N	2026-04-18 04:51:50.66975+00
413	5	update_company_settings	settings	\N	\N	\N	2026-04-18 05:02:22.529349+00
414	5	update_company_settings	settings	\N	\N	\N	2026-04-18 05:05:03.752567+00
415	5	login	auth	\N	\N	\N	2026-04-18 05:10:46.909106+00
416	15	login	auth	\N	\N	\N	2026-04-18 05:13:51.961637+00
417	5	login	auth	\N	\N	\N	2026-04-18 06:10:06.131757+00
418	5	login	auth	\N	\N	\N	2026-04-18 06:47:23.167948+00
419	15	login	auth	\N	\N	\N	2026-04-18 06:53:28.312557+00
420	5	login	auth	\N	\N	\N	2026-04-18 06:57:24.114113+00
421	15	login	auth	\N	\N	\N	2026-04-18 06:57:35.808303+00
422	15	login	auth	\N	\N	\N	2026-04-18 06:57:44.025646+00
423	5	login	auth	\N	\N	\N	2026-04-18 07:41:17.205255+00
424	16	update_avatar	auth	\N	\N	\N	2026-04-18 07:44:40.834329+00
425	5	update_company_settings	settings	\N	\N	\N	2026-04-18 08:18:47.791992+00
426	5	login	auth	\N	\N	\N	2026-04-18 08:23:42.21091+00
427	15	login	auth	\N	\N	\N	2026-04-18 09:28:22.128853+00
428	5	login	auth	\N	\N	\N	2026-04-18 10:17:27.776167+00
429	15	login	auth	\N	\N	\N	2026-04-18 10:53:31.771191+00
430	15	login	auth	\N	\N	\N	2026-04-18 12:04:08.624995+00
431	5	login	auth	\N	\N	\N	2026-04-18 17:38:20.038703+00
432	5	update_company_settings	settings	\N	\N	\N	2026-04-19 16:27:30.061887+00
433	5	update_company_settings	settings	\N	\N	\N	2026-04-19 16:29:03.514442+00
434	5	update_company_settings	settings	\N	\N	\N	2026-04-19 16:54:42.555143+00
435	5	update_avatar	auth	\N	\N	\N	2026-04-19 16:56:46.386618+00
436	15	login	auth	\N	\N	\N	2026-04-19 17:31:35.945853+00
437	15	update_avatar	auth	\N	\N	\N	2026-04-19 17:32:14.763397+00
438	5	login	auth	\N	\N	\N	2026-04-19 17:33:26.590149+00
439	15	login	auth	\N	\N	\N	2026-04-19 17:34:19.455959+00
440	15	clear_avatar	auth	\N	\N	\N	2026-04-19 17:43:23.387572+00
441	15	login	auth	\N	\N	\N	2026-04-21 04:25:09.476891+00
442	15	login	auth	\N	\N	\N	2026-04-21 04:33:51.802939+00
443	15	login	auth	\N	\N	\N	2026-04-21 06:04:26.974287+00
444	5	login	auth	\N	\N	\N	2026-04-21 06:04:44.706058+00
445	5	login	auth	\N	\N	\N	2026-04-21 06:23:21.907636+00
446	5	login	auth	\N	\N	\N	2026-04-22 05:34:17.33387+00
447	15	login	auth	\N	\N	\N	2026-04-25 13:10:41.664964+00
448	5	login	auth	\N	\N	\N	2026-05-02 04:59:45.825847+00
449	5	login	auth	\N	\N	\N	2026-05-02 07:47:09.173951+00
450	5	login	auth	\N	\N	\N	2026-05-05 05:13:21.111299+00
451	5	login	auth	\N	\N	\N	2026-05-05 05:19:18.135704+00
452	15	login	auth	\N	\N	\N	2026-05-05 05:41:09.92619+00
453	15	login	auth	\N	\N	\N	2026-05-05 07:29:11.005402+00
454	5	login	auth	\N	\N	\N	2026-05-05 09:38:29.830595+00
455	15	login	auth	\N	\N	\N	2026-05-07 04:13:32.499115+00
456	15	login	auth	\N	\N	\N	2026-05-09 07:38:03.096463+00
457	15	login	auth	\N	\N	\N	2026-05-09 09:22:13.778925+00
458	15	login	auth	\N	\N	\N	2026-05-11 03:48:53.420718+00
459	15	login	auth	\N	\N	\N	2026-05-14 06:12:10.749561+00
460	15	login	auth	\N	\N	\N	2026-05-14 06:22:42.564731+00
461	15	login	auth	\N	\N	\N	2026-05-14 06:23:04.261819+00
462	5	login	auth	\N	\N	\N	2026-05-14 06:23:12.480825+00
463	5	update_company_settings	settings	\N	\N	\N	2026-05-14 06:26:12.27878+00
464	5	update_company_settings	settings	\N	\N	\N	2026-05-14 06:26:18.315894+00
465	5	update_company_settings	settings	\N	\N	\N	2026-05-14 06:26:24.356771+00
466	5	update_company_settings	settings	\N	\N	\N	2026-05-14 06:26:30.405337+00
467	5	update_company_settings	settings	\N	\N	\N	2026-05-14 06:26:36.44321+00
468	5	login	auth	\N	\N	\N	2026-05-15 11:46:45.060848+00
469	5	login	auth	\N	\N	\N	2026-05-15 11:55:01.656821+00
470	5	login	auth	\N	\N	\N	2026-05-16 03:47:15.640778+00
\.


--
-- Data for Name: bom; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bom (id, product_id, name, version, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: bom_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bom_items (id, bom_id, component_id, quantity, unit) FROM stdin;
\.


--
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.brands (id, name, created_at, tenant_id) FROM stdin;
1	Igloo	2026-04-09 08:47:18.70609+00	1
2	Kool Roof Tile	2026-04-18 07:43:59.868132+00	1
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, created_at, tenant_id) FROM stdin;
3	Manhole	2026-04-13 09:56:54.953156+00	1
5	Interlock Block	2026-04-13 09:57:30.258782+00	1
1	Roof Tiles	2026-04-09 08:47:44.793056+00	1
4	Kerbstone	2026-04-13 09:57:08.842691+00	1
6	Kool Roof Tile	2026-04-16 07:11:10.710881+00	1
\.


--
-- Data for Name: comm_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comm_logs (id, lead_id, channel, recipient, subject, body, status, sent_by, sent_at, tenant_id) FROM stdin;
1	\N	whatsapp	09442858320	\N	hi	sent	\N	2026-04-03 08:46:25.513319+00	1
2	\N	whatsapp	09442858320	\N	Hi {{name}}, this is a quick follow-up regarding your recent inquiry. Reply YES to schedule a call.	sent	\N	2026-04-03 08:46:35.033707+00	1
\.


--
-- Data for Name: comm_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comm_templates (id, name, channel, subject, body, created_at, tenant_id) FROM stdin;
1	Demo ??? Welcome email	email	Thanks for contacting us	Hi {{name}}, thank you for your interest. A representative will reach out within one business day.	2026-04-01 05:24:46.122238+00	1
2	Demo ??? Follow-up WhatsApp	whatsapp	\N	Hi {{name}}, this is a quick follow-up regarding your recent inquiry. Reply YES to schedule a call.	2026-04-01 05:24:46.122238+00	1
\.


--
-- Data for Name: company_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.company_settings (id, company_name, gstin, address, phone, email, logo_url, currency, fiscal_year_start, updated_at, invoice_tagline, payment_terms, invoice_bank_details, bank_name, bank_branch, bank_account_number, bank_ifsc, favicon_url, invoice_logo_url, tenant_id, invoice_footer_content) FROM stdin;
1	IGLOO TILES,	33AADFI0510N1ZQ	BUILDING MATERIAL MANUFACTURE,\nNo-1,Salakadu Village,\nEdumalai Road,\nAyyampalayam,\nManachanallur,\nTrichy-621005,\nTamilnadu.\nE-Mail : iglootiles2010@gmail.com\n+91 8048040547.\nwww.iglootiles.in	+91 9344036674	iglootiles2010@gmail.com	/uploads/company/logo-1776166191837.png	???	2026-03-30	2026-05-14 06:26:34.432256+00		Quotation Validity: 30 days.\n\n1] Order Confirmation 50% Advance Need.\n2] Payment Terms 100% is Required before Despatch.\n3] Material Delivery Time 2 to 5 days depending on-site Distance.\n4] Materials Returns are not Acceptable.\n5] Material Unloading will be the customers Responsibility.\n6] Online Payment Only Acceptable Company Account.\nContact us if you have any questions +91 9344036674.	\N	Karur Vysya Bank,	Srirangam,Trichy	1276010000000839.	KVBL0001276	/uploads/company/favicon-1776166196365.png	/uploads/bucket/company/invoice-logos/1776617676680-3251l097.png	1	\n
\.


--
-- Data for Name: crm_platforms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crm_platforms (id, name, created_at) FROM stdin;
1	Facebook	2026-04-11 05:18:36.962434+00
2	Instagram	2026-04-11 05:18:36.962434+00
3	Google	2026-04-11 05:18:36.962434+00
4	WhatsApp	2026-04-11 05:18:36.962434+00
5	Walk-in	2026-04-11 05:18:36.962434+00
6	Referral	2026-04-11 05:18:36.962434+00
7	Website	2026-04-11 05:18:36.962434+00
\.


--
-- Data for Name: crm_priorities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crm_priorities (id, name, color, created_at) FROM stdin;
1	Hot	red	2026-04-11 05:18:36.962434+00
2	Warm	amber	2026-04-11 05:18:36.962434+00
3	Cold	blue	2026-04-11 05:18:36.962434+00
\.


--
-- Data for Name: crm_segments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crm_segments (id, name, created_at) FROM stdin;
1	B2B	2026-04-11 05:18:36.962434+00
2	B2C	2026-04-11 05:18:36.962434+00
3	Enterprise	2026-04-11 05:18:36.962434+00
4	SMB	2026-04-11 05:18:36.962434+00
5	Startup	2026-04-11 05:18:36.962434+00
7	B2Ch	2026-04-14 11:20:03.039413+00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (id, name, email, phone, gstin, lead_id, is_active, created_at, created_by, billing_address, shipping_address, tenant_id) FROM stdin;
9	Sundarrajan A	jaisrugarments@gmail.com	p:+919843243642	\N	335	t	2026-04-13 08:30:50.740712+00	\N	Tiruppur, Tiruppur, z:	\N	1
10	Chandru Marappan	chandrumarappan@gmail.com	p:+919842322565	\N	334	t	2026-04-13 09:58:38.711506+00	\N	Tiruppur, Tamilnadu, z:641666	\N	1
11	Iyya Ppan	lakshmielectricalshardwares23@gmail.com	p:+918124429424	\N	333	t	2026-04-13 11:03:32.923004+00	\N	Tiruvannamalai, Tamilnadu, z:606702	\N	1
12	Mani Barathi	gishalborre6@hotmail.com	p:+918667390581	\N	343	t	2026-04-14 08:29:43.372718+00	\N	Thiruvannamalai, India, z:606705	\N	1
13	SANKAR.D	sankararul83@gmail.com	p:+919942597799	\N	346	t	2026-04-14 14:38:37.619662+00	\N	MALLASAMUDRAM, TAMILNADU, z:637503	\N	1
14	Dr.Saravanan,		9842781831		350	t	2026-04-15 06:26:20.041448+00	5	Thiruverumbur,Trichy.	\N	1
15	RC-CONSTRUCTION,		9444061805		351	t	2026-04-15 10:16:52.709027+00	5	Billing Adress:\nRC-Construction,No-20,anderson road,ayanavaram,chennai,600023.GST:33ABAFR9373G1Z2.\nShipping Adress:\nRC-THILLAI,7th Cross Street,Thillai Nagar,Trichy-GST:33ABAFR9373G1Z2.	\N	1
16	M. S .CONSTRUCTION,	\N	8940624687.	\N	352	t	2026-04-15 10:51:47.592502+00	\N	NO.40A,  MICHAEL NAGAR, SANKAR NAGAR, THALIYUTHU, TIRUNELVELI-627357.	\N	1
17	Yuvaraj Rubini	youvaraj.ms@gmail.com	p:+918939355466	\N	342	t	2026-04-15 11:29:56.766401+00	\N	Chennai, TN, z:600097	\N	1
23	Foster Energy Pvt Ltd,		7448890037		\N	t	2026-04-16 05:03:15.923334+00	15	19th Cross St, Village High Rd, Sholinganallur, Chennai, Tamil Nadu 600119,	Solar Power Project,\nMudukkur,Tanjore,Tamilnadu.	1
18	Mohamed Shabirsha	shabinsw@gmail.com	p:+919952236637	\N	341	t	2026-04-15 11:33:30.046793+00	\N	avinachi, Tamilnadu, z:641603	\N	1
19	R SANJAY ( SRK CONSTRUCTION  )	sanjaysa@gmail.com	p:+919282425260	\N	337	t	2026-04-15 11:35:46.060998+00	\N	Chennai, tamilnadu, z:600049	\N	1
20	Guru Bhoopthi	gurubhoopathi1981@gmail.com	p:+919043424113	\N	339	t	2026-04-15 12:08:19.031316+00	\N	Salem, Tamil Nadu, z:636003	\N	1
21	Arumuga Ramesh Sanmugasundaram	arumugaramesh19@gmail.com	917397256938	\N	330	t	2026-04-15 12:21:39.85877+00	\N	chennai city, tamilnadu chennai, 7397256938	\N	1
22	Foster Energy Pvt Ltd,	\N	7448890037	\N	354	t	2026-04-16 04:56:46.564205+00	\N	Billing Adress:\n19th Cross St, Village High Rd, Sholinganallur, Chennai, Tamil Nadu 600119.\nShipping Adress:\nSolar Power Projects,\nMudukkur,Tanjore,Tamilnadu,	19th Cross St, Village High Rd, Sholinganallur, Chennai, Tamil Nadu 600119.	1
24	SYED AMMAAL ARTS & SCIENCE COLLEGE,		09442858320		\N	t	2026-04-16 07:23:52.03484+00	5	Dr.E.M.Abdullah Nagar,Devipattinam Road,\nKootampuli,Pullangudi(Post),	abibulla,karaikudi,	1
26	Vinayakam R Vinayagam	zvinayagam@gmail.com	p:+919597206403		336	t	2026-04-16 12:53:03.949485+00	5	Pondicherry, z:	Pondicherry	1
27	SRI KARTHIK ENTERPRISES	srikarthikenterprisess@gmail.com	9944663674		364	t	2026-04-17 07:47:10.750052+00	15	No - 27 /1051 Sri Ram Nagar, First Street, Ellichathiram Road, Vazhudhareddy and post Villupuram,\nTAMILNADU - 605401.MOBILE - 9944663674, 9843430086.GSTIN - 33ACNFS4904N1ZO.	New Billing Address	1
28	Mr.Gopalakrishnan,	\N	9245147879	\N	373	t	2026-04-17 13:38:02.823519+00	5	Mangadu,Chennai, Tamilnadu,	Mangadu,Chennai, Tamilnadu,	1
30	Shri Suresh Timbers & Tiles		9841334453	33ABTFS3122K1ZY	\N	t	2026-04-18 06:19:48.646472+00	5	Shri Suresh Timbers & Tiles,\nGST Road, Tambaram Sanitorium\nChennai - 47	Shri Suresh Timbers & Tiles,\nGST Road, Tambaram Sanitorium\nChennai - 47	1
31	Shri Suresh Timbers & Tiles	\N	9841334453	\N	376	t	2026-04-18 09:39:18.74272+00	5	Shri Suresh Timbers & Tiles\nGST Road, Tambaram Sanitorium\nChennai - 47 , Tamil Nadu	Shri Suresh Timbers & Tiles\nGST Road, Tambaram Sanitorium\nChennai - 47 , Tamil Nadu	1
32	ANVI GROUPS,	sureshr158@gmail.com	+919884974505	\N	379	t	2026-04-18 10:21:46.995518+00	5	Karaikal Nagapattinam,	\N	1
33	Asian Building Material Pvt Ltd,	\N	9092237129	\N	380	t	2026-04-18 10:45:41.92286+00	5	9R7M+QR8, No 13/A1, GH Rd, Chalai Bazar, Ramanathapuram, Tamil Nadu 623502	9R7M+QR8, No 13/A1, GH Rd, Chalai Bazar, Ramanathapuram, Tamil Nadu 623502	1
34	Sri Jayram Agencies	\N	9842797995	\N	389	t	2026-04-21 04:34:56.24578+00	15	\N	\N	1
36	SREE LORD VENKATACHALAPATHI EDUCATIONAL TRUST,	\N	+91 8800973322	\N	398	t	2026-05-02 07:51:43.810631+00	5	TRICHY NAMAKKAL MAIN ROAD, TRICHY, THOTTIAM,TIRUCHIRAPPALLI,621203	\N	1
37	Upendra Traders	\N	9894807318	\N	410	t	2026-05-05 05:19:43.628036+00	5	\N	\N	1
38	M/s Kuviyam Infra Developers Pvt Ltd	\N	9865057517	\N	411	t	2026-05-05 07:33:33.807742+00	15	14, Gandhiji Street, Malaiyappa Nagar\nAriyamangalam, Trichy- 620010	\N	1
39	O.N.Boss	bossdevi2367@gmail.com	9150025097	\N	419	t	2026-05-07 04:15:38.802048+00	15	Batlgundu \nDindugal	\N	1
40	Sri Ramachandra Traders	SRT04072018@gmail.com	98405 73475	\N	433	t	2026-05-09 09:27:49.872335+00	15	Plot No 20 , Seethapathy Street \nAmirthammal Nagar, Lotus Colony , 01st Sreet\nMadhavaram, Chennai	\N	1
35	Mr. Gangatharan	\N	9381031440	\N	390	t	2026-04-21 06:07:46.597353+00	5	Sooriur ,\nTrichy\nPho: 9381031440	Sooriur ,\nTrichy\nPho: 9381031440	1
41	Mr. Jayaraj .s	\N	9600162467	\N	450	t	2026-05-14 06:15:05.967373+00	15	NPL Devi #111, 5th Floor ,\nLB Road , Thiruvanmiyur\nChennai  - 41	NPL Devi #111, 5th Floor ,\nLB Road , Thiruvanmiyur\nChennai  - 41	1
42	PSN Construction	\N	+91 94433 68659	\N	456	t	2026-05-15 11:50:24.150258+00	5	72nd floor Janappachatram Kiribati nagar,Chennai-67	\N	1
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employees (id, user_id, employee_code, department, designation, date_of_joining, date_of_birth, phone, address, bank_account, ifsc_code, pan_number, basic_salary, is_active, created_at, tenant_id) FROM stdin;
4	\N	001	Sales	Manager	2026-04-01	\N	9344036674	\N	\N	\N	\N	30000.00	t	2026-04-16 06:51:16.098731+00	1
5	\N	002	Sales	Marketting 	2026-04-01	\N	9363736674	\N	\N	\N	\N	15000.00	t	2026-04-16 06:53:06.450213+00	1
6	\N	003	Sales	Sales Executive	2026-04-01	\N	9363136674	\N	\N	\N	\N	20000.00	t	2026-04-16 06:54:39.515501+00	1
7	\N	004	Accounts	Accounts	2026-04-15	\N	6381336674	\N	\N	\N	\N	10000.00	t	2026-04-16 06:56:10.25947+00	1
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.expenses (id, account_id, amount, expense_date, category, description, receipt_url, approved_by, created_by, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: grn; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grn (id, grn_number, po_id, received_at, notes, created_by, tenant_id) FROM stdin;
\.


--
-- Data for Name: grn_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grn_items (id, grn_id, product_id, quantity, warehouse_id, tenant_id) FROM stdin;
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoice_items (id, invoice_id, product_id, description, quantity, unit_price, gst_rate, cgst, sgst, igst, total, discount) FROM stdin;
13	76	52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	100.000	260.00	18.00	1983.05	1983.05	0.00	26000.00	0.00
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoices (id, invoice_number, customer_id, order_id, invoice_date, due_date, subtotal, cgst, sgst, igst, total_amount, status, notes, created_by, created_at, reference_no, gst_type, tax_type, discount_type, discount_amount, shipping_amount, extra_discount, round_off, payment_terms, payment_method, state_of_supply, approval_status, approved_by, approved_at, tenant_id) FROM stdin;
76	INV-1776323717308	14	\N	2026-04-16	\N	22033.90	1983.05	1983.05	0.00	26000.00	unpaid	\N	16	2026-04-16 07:15:17.188154+00	\N	intra_state	exclusive	percentage	0.00	0.00	0.00	0.00	\N	\N	\N	approved	5	2026-04-16 07:15:17.308+00	1
\.


--
-- Data for Name: journal_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.journal_entries (id, entry_date, reference, description, created_by, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: journal_lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.journal_lines (id, entry_id, account_id, debit, credit, description, tenant_id) FROM stdin;
\.


--
-- Data for Name: lead_activities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_activities (id, lead_id, user_id, type, description, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: lead_followups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_followups (id, lead_id, assigned_to, due_date, description, is_done, created_at, tenant_id) FROM stdin;
15	332	15	2026-04-12 18:30:00+00	contacted	f	2026-04-13 11:10:15.799124+00	1
16	343	16	2026-04-18 10:18:00+00	\N	f	2026-04-14 10:18:13.211009+00	1
14	333	16	2026-04-16 11:09:00+00	meeting	f	2026-04-13 11:10:03.821694+00	1
17	355	15	2026-04-29 18:30:00+00	\N	f	2026-04-18 05:26:07.428183+00	\N
18	456	5	2026-05-30 12:01:00+00	\N	f	2026-05-15 12:01:08.38812+00	\N
19	456	15	2026-05-30 12:01:00+00	\N	f	2026-05-15 12:01:13.74471+00	\N
\.


--
-- Data for Name: lead_form_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_form_submissions (id, form_id, data, lead_id, submitted_at) FROM stdin;
\.


--
-- Data for Name: lead_forms; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_forms (id, name, fields, source, is_active, created_at, title, form_key, default_source_id, default_stage_id, assigned_to) FROM stdin;
\.


--
-- Data for Name: lead_platform_facebook_leads; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_platform_facebook_leads (id, page_id, form_id, facebook_lead_id, created_time, field_data, raw_data, crm_lead_id, created_at, updated_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: lead_platform_facebook_pages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_platform_facebook_pages (id, page_id, page_name, page_access_token, lead_source_id, created_at, updated_at, page_url, tenant_id) FROM stdin;
\.


--
-- Data for Name: lead_platform_google_sheets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_platform_google_sheets (id, sheet_url, sheet_gid, lead_source_id, is_active, created_at, updated_at, data_start_row, tenant_id) FROM stdin;
8	https://docs.google.com/spreadsheets/d/1JuvkN0CK4UAOMI5s0MBVE0fM4FK7kXlViTVbq60i14Q/edit?usp=sharing	\N	2	t	2026-04-13 07:48:35.367017+00	2026-04-13 07:48:35.367017+00	58	1
9	https://docs.google.com/spreadsheets/d/1hfPJLIF0C3-avKx89r68aJoXibLEp2sUQGVSaqesBDk/edit?usp=sharing	\N	2	t	2026-04-13 07:56:57.53661+00	2026-04-13 07:56:57.53661+00	27	1
10	https://docs.google.com/spreadsheets/d/14FMUW1X5WRxLDr7Fa3cIaVf3wo8MJqzv-nlKgeLujG4/edit?usp=sharing	\N	2	t	2026-04-17 08:04:37.560609+00	2026-04-17 08:04:37.560609+00	245	1
\.


--
-- Data for Name: lead_sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_sources (id, name) FROM stdin;
1	Website
2	Facebook Ads
3	Google Ads
5	Cold Call
6	LinkedIn
7	Walk-in
8	WhatsApp
9	Instagram
11	Email Campaign
24	Google Sheet
\.


--
-- Data for Name: lead_stages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lead_stages (id, name, "position") FROM stdin;
1	New	0
2	Contacted	1
3	Qualified	2
4	Proposal Sent	3
5	Negotiation	4
6	Won	5
7	Lost	6
8	Quotation Sent	7
10	RNR	8
\.


--
-- Data for Name: leads; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leads (id, name, email, phone, company, source_id, stage_id, assigned_to, custom_fields, notes, is_converted, created_at, updated_at, priority, lead_score, lead_segment, job_title, deal_size, website, address, tags, assigned_manager_id, created_by, product_category, tenant_id, shipping_address) FROM stdin;
382	Rajakumar Ramaiah	trycity2006@gmail.com	p:+919486066096	\N	2	1	\N	{"zip": "z:", "city": "Truchy", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 253, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:944577661551163", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-19 06:50:27.036275+00	2026-04-19 06:50:27.036275+00	warm	0.00	\N	\N	\N	\N	Truchy, Tamilnadu, z:	{}	\N	\N	\N	\N	\N
377	Vinoth Devendra	vinothcivilsix@gmail.com	p:+919994508323	\N	9	1	\N	{"zip": "z:600001", "city": "Salem", "state": "OR", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 252, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1335920075107561", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-18 08:20:25.931474+00	2026-04-18 08:20:25.931474+00	warm	0.00	\N	\N	\N	\N	Salem, OR, z:600001	{}	\N	\N	\N	\N	\N
384	Anbarasan	\N	p:+918870601309	\N	2	1	\N	{"zip": "z:613001", "city": "Thanjavur", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 254, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1534181728308323", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-19 14:00:29.116818+00	2026-04-19 14:10:27.391432+00	warm	0.00	\N	\N	\N	\N	Thanjavur, z:613001	{}	\N	\N	\N	\N	\N
376	Shri Suresh Timbers & Tiles	\N	9841334453	\N	8	3	15	\N	\N	t	2026-04-18 06:13:45.839604+00	2026-04-18 09:39:18.74272+00	hot	0.00	B2Ch	\N	\N	\N	Shri Suresh Timbers & Tiles\nGST Road, Tambaram Sanitorium\nChennai - 47 , Tamil Nadu	{}	\N	5	Kool Roof Tile	1	Shri Suresh Timbers & Tiles\nGST Road, Tambaram Sanitorium\nChennai - 47 , Tamil Nadu
380	Asian Building Material Pvt Ltd,	\N	9092237129	\N	8	6	5	\N	\N	t	2026-04-18 10:45:33.946513+00	2026-04-19 02:31:29.084687+00	hot	0.00	B2Ch	\N	\N	\N	9R7M+QR8, No 13/A1, GH Rd, Chalai Bazar, Ramanathapuram, Tamil Nadu 623502	{}	\N	5	Roof Tiles	1	9R7M+QR8, No 13/A1, GH Rd, Chalai Bazar, Ramanathapuram, Tamil Nadu 623502
381	vinoth Devendra	\N	9994508323	\N	2	2	16	\N	\N	f	2026-04-18 12:07:50.900899+00	2026-04-18 12:07:50.900899+00	warm	0.00	\N	\N	\N	\N	Salem	{}	\N	5	Manhole	1	\N
373	Mr.Gopalakrishnan,	\N	9245147879	\N	2	4	15	\N	\N	t	2026-04-17 13:37:45.130813+00	2026-04-19 02:39:21.785934+00	hot	0.00	\N	\N	\N	\N	Mangadu,Chennai, Tamilnadu,	{}	15	5	Manhole	1	\N
363	Anwar Basha	\N	p:+917339677694	\N	2	1	\N	{"zip": "z:", "city": "tuticorin", "state": "tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 249, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:841492658959926", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-17 07:30:19.924089+00	2026-04-17 07:50:20.09433+00	warm	0.00	\N	\N	\N	\N	tuticorin, tamil nadu, z:	{}	\N	\N	\N	1	\N
286	RAJA R K	rkraja007@gmail.com	p:+918825822466	\N	2	1	\N	{"zip": "z:", "city": "kotagiri", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 238, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:979775505229982", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:03.837107+00	2026-04-17 08:02:30.222267+00	warm	0.00	\N	\N	\N	\N	kotagiri, Tamil Nadu, z:	{}	\N	\N	\N	1	kotagiri, Tamil Nadu, z:
350	Dr.Saravanan,	\N	9842781831	\N	8	6	\N	\N	customer want to kerbstone	f	2026-04-15 06:17:02.433896+00	2026-04-16 07:38:31.618674+00	hot	0.00	B2B	\N	26000.00	\N	Thiruverumbur,Trichy.	{}	\N	5	Kerbstone	1	Thiruverumbur,Trichy.
383	Rajakumar Ramaiah	trycity2006@gmail.com	p:+919486066096	\N	2	1	\N	{"zip": "z:", "city": "Truchy", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 253, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:944577661551163", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-19 06:50:28.918163+00	2026-05-17 13:20:04.396078+00	warm	0.00	\N	\N	\N	\N	Truchy, Tamilnadu, z:	{}	\N	\N	\N	\N	\N
385	Anbarasan	\N	p:+918870601309	\N	2	1	\N	{"zip": "z:613001", "city": "Thanjavur", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 254, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1534181728308323", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-19 14:00:30.344305+00	2026-05-17 13:20:04.400334+00	warm	0.00	\N	\N	\N	\N	Thanjavur, z:613001	{}	\N	\N	\N	\N	\N
378	Vinoth Devendra	vinothcivilsix@gmail.com	p:+919994508323	\N	9	1	\N	{"zip": "z:600001", "city": "Salem", "state": "OR", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 252, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1335920075107561", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-18 08:20:25.936963+00	2026-05-17 13:20:04.391938+00	warm	0.00	\N	\N	\N	\N	Salem, OR, z:600001	{}	\N	\N	\N	\N	\N
309	Nalla Arivazhagan	deivaarivu@gmail.com	p:+919841616979	\N	2	1	\N	{"zip": "z:600070", "city": "Chennai ,70", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 79, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1271557064470789", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:50.916017+00	2026-05-17 13:20:01.682644+00	warm	0.00	\N	\N	\N	\N	Chennai ,70, Tamilnadu, z:600070	{}	\N	\N	\N	1	Chennai ,70, Tamilnadu, z:600070
308	Padmanabhan Ramanathan	padmanathan99526@gmail.com	p:+919952667411	\N	2	1	\N	{"zip": "z:", "city": "Chinna Thirupathi", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 78, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:925220100304400", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:50.67618+00	2026-05-17 13:20:01.677848+00	warm	0.00	\N	\N	\N	\N	Chinna Thirupathi, Tamilnadu, z:	{}	\N	\N	\N	1	Chinna Thirupathi, Tamilnadu, z:
291	Er Askar Ali S	askaralisa_sa@yahoo.com	p:+919865607797	\N	2	1	\N	{"zip": "z:", "city": "rameswaram tamilnadu", "state": "tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 61, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1586159029335295", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:46.598582+00	2026-05-17 13:20:01.602407+00	warm	0.00	\N	\N	\N	\N	rameswaram tamilnadu, tamilnadu, z:	{}	\N	\N	\N	1	rameswaram tamilnadu, tamilnadu, z:
379	ANVI GROUPS,	sureshr158@gmail.com	+919884974505	\N	2	8	15	\N	\N	t	2026-04-18 10:20:55.95644+00	2026-04-25 13:13:33.300862+00	hot	0.00	B2Ch	\N	\N	\N	Karaikal Nagapattinam,	{}	\N	5	Manhole	1	\N
265	sargunam  R	rkbrothershardwares@gmail.com	p:+918838004230	\N	2	1	\N	{"zip": "z:", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 217, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:935197415985621", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:59.074122+00	2026-04-17 08:02:24.995584+00	warm	0.00	\N	\N	\N	\N	Chennai, tamilnadu, z:	{}	\N	\N	\N	1	Chennai, tamilnadu, z:
346	SANKAR.D	sankararul83@gmail.com	p:+919942597799	\N	2	4	16	{"zip": "z:637503", "city": "MALLASAMUDRAM", "state": "TAMILNADU", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 243, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:982396877781357", "google_sheet_config_id": "7"}	Imported from Google Sheet	t	2026-04-14 14:30:20.010056+00	2026-04-15 05:15:56.806762+00	warm	0.00	\N	\N	\N	\N	MALLASAMUDRAM, TAMILNADU, z:637503	{}	\N	\N	\N	1	MALLASAMUDRAM, TAMILNADU, z:637503
362	Anwar Basha	\N	p:+917339677694	\N	2	1	\N	{"zip": "z:", "city": "tuticorin", "state": "tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 249, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:841492658959926", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-17 07:30:15.191002+00	2026-04-17 08:02:32.924616+00	warm	0.00	\N	\N	\N	\N	tuticorin, tamil nadu, z:	{}	\N	\N	\N	1	\N
354	Foster Energy Pvt Ltd,	\N	7448890037	\N	2	4	15	\N	Customer want to kerbstone 670 numbers	t	2026-04-16 04:56:40.890332+00	2026-04-19 02:41:11.834288+00	hot	5.00	B2Ch	\N	160800.00	\N	19th Cross St, Village High Rd, Sholinganallur, Chennai, Tamil Nadu 600119.	{}	\N	15	Krebstone	1	Solar Power Projects,\nMudukkur,Tanjore,Tamilnadu,
315	Manikandan M	srivinayagacivil9093@gmail.com	919843694731	\N	2	1	\N	{"zip": "607202", "city": "Kallakurichi", "state": "Tamil nadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 30, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1616265489486936", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:40.053403+00	2026-05-17 13:20:02.977448+00	warm	0.00	\N	\N	\N	\N	Kallakurichi, Tamil nadu, 607202	{}	\N	\N	\N	1	Kallakurichi, Tamil nadu, 607202
328	Wesly Jc	weslypraveen35@gmail.com	919025689618	\N	2	1	\N	{"zip": "600052", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 43, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "3034292233424506", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:43.458562+00	2026-05-17 13:20:03.095346+00	warm	0.00	\N	\N	\N	\N	Chennai, tamilnadu, 600052	{}	\N	\N	\N	1	Chennai, tamilnadu, 600052
336	Vinayakam R Vinayagam	zvinayagam@gmail.com	p:+919597206403	\N	2	1	\N	{"zip": "z:", "city": "Pondicherry", "state": null, "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 51, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1605887243798415", "google_sheet_config_id": "9"}	Imported from Google Sheet	t	2026-04-13 12:20:28.854582+00	2026-05-17 13:20:03.192505+00	warm	0.00	\N	\N	\N	\N	Pondicherry, z:	{}	\N	\N	\N	1	Pondicherry
348	Dharmaraj Raja	dharmaraj1968@gmail.com	p:+919688881522	\N	9	1	16	{"zip": "z:623708", "city": "Kamuthi. Peraiyur", "state": "Peraiyur", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 54, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:786971757573119", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-15 05:50:33.904579+00	2026-05-17 13:20:03.212892+00	cold	0.00	\N	\N	\N	\N	Kamuthi. Peraiyur, Peraiyur, z:623708	{}	\N	\N	\N	1	Kamuthi. Peraiyur, Peraiyur, z:623708
325	Er. Sathish	saas78349@gmail.com	917418011363	\N	9	1	\N	{"zip": "639104", "city": "Coimbatore", "state": "Tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 40, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1874167613265598", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:42.760113+00	2026-05-17 13:20:03.059074+00	warm	0.00	\N	\N	\N	\N	Coimbatore, Tamilnadu, 639104	{}	\N	\N	\N	1	Coimbatore, Tamilnadu, 639104
366	Karthik	Karthik7085@gnail.com	p:+918056644945	\N	9	1	\N	{"zip": "z:603103", "city": "Chennai", "state": "India", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 245, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:956064466781395", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-17 08:04:48.431132+00	2026-05-17 13:20:04.363474+00	warm	0.00	\N	\N	\N	\N	Chennai, India, z:603103	{}	\N	\N	\N	1	\N
335	Sundarrajan A	jaisrugarments@gmail.com	p:+919843243642	\N	2	1	\N	{"zip": "z:", "city": "Tiruppur", "state": "Tiruppur", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 50, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:934122032806621", "google_sheet_config_id": "9"}	Imported from Google Sheet	t	2026-04-13 07:57:45.085117+00	2026-05-17 13:20:03.166324+00	warm	0.00	B2B	\N	\N	\N	Tiruppur, Tiruppur, z:	{}	15	\N	\N	1	Tiruppur, Tiruppur, z:
374	THOUSEEF	thouseef96@gmail.com	p:+917200786482	\N	9	1	\N	{"zip": "z:632509", "city": "Vellore", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 250, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1996567297736150", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-17 15:20:29.778182+00	2026-05-17 13:20:04.383979+00	warm	0.00	\N	\N	\N	\N	Vellore, Tamil Nadu, z:632509	{}	\N	\N	\N	1	\N
322	S Selvaraj	dealselj@gmail.com	918903428877	\N	2	1	\N	{"zip": null, "city": "salem", "state": "yes", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 37, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "780692501557797", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:42.06183+00	2026-05-17 13:20:03.030157+00	warm	0.00	\N	\N	\N	\N	salem, yes	{}	\N	\N	\N	1	salem, yes
360	svs manian	skn5602@gmail.com	p:+918667012573	\N	2	2	16	{"zip": "z:", "city": "coimbatore", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 248, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1741274657051690", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-17 07:00:20.996791+00	2026-04-21 06:13:17.71828+00	warm	0.00	\N	\N	\N	\N	coimbatore, tamilnadu, z:	{}	\N	\N	Manhole	1	\N
260	P Vetriselvan Vetri	pvetriselvanvetri@gmail.com	p:+919585818419	\N	2	1	\N	{"zip": "z:", "city": "thiruppattur osur", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 212, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:957137880297613", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:57.939843+00	2026-04-17 08:02:23.768401+00	warm	0.00	\N	\N	\N	\N	thiruppattur osur, Tamilnadu, z:	{}	\N	\N	\N	1	thiruppattur osur, Tamilnadu, z:
281	DJ. VENGADESSANE	djvengadessane@gmail.com	p:+919442105035	\N	2	1	\N	{"zip": "z:605001", "city": "Pondicherry", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 233, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1008700415177615", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:02.703264+00	2026-04-17 08:02:28.986763+00	warm	0.00	\N	\N	\N	\N	Pondicherry, z:605001	{}	\N	\N	\N	1	Pondicherry, z:605001
264	Chinna Raja.P	psraja21@gmail.com	p:+918608203328	\N	2	1	\N	{"zip": "z:625520", "city": "Theni", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 216, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1695593185129059", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:58.846793+00	2026-04-17 08:02:24.751326+00	warm	0.00	\N	\N	\N	\N	Theni, Tamilnadu, z:625520	{}	\N	\N	\N	1	Theni, Tamilnadu, z:625520
262	Suresh	kancharla7799@gmail.com	p:+919894357799	\N	9	1	\N	{"zip": "z:602001", "city": "Thiruvallur", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 214, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:3480235082141985", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:58.393143+00	2026-04-17 08:02:24.257933+00	warm	0.00	\N	\N	\N	\N	Thiruvallur, Tamil Nadu, z:602001	{}	\N	\N	\N	1	Thiruvallur, Tamil Nadu, z:602001
352	M. S .CONSTRUCTION,	\N	8940624687.	\N	8	8	5	\N	Customer want to igloo tile 20 mm thick 15000	t	2026-04-15 10:50:31.283642+00	2026-04-19 02:42:01.155993+00	hot	0.00	\N	\N	900000.00	\N	NO.40A,  MICHAEL NAGAR, SANKAR NAGAR, THALIYUTHU, TIRUNELVELI-627357.\nGST NO : 33AAQFM4354F1Z8.	{}	\N	5	Tiles	1	NO.40A,  MICHAEL NAGAR, SANKAR NAGAR, THALIYUTHU, TIRUNELVELI-627357.\nGST NO : 33AAQFM4354F1Z8.
263	Murugen Mb	srijayrammlr@gmail.com	p:+919842797995	\N	2	1	\N	{"zip": "z:638106", "city": "MULANUR", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 215, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4334621940082641", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:58.619714+00	2026-04-17 08:02:24.50198+00	warm	0.00	\N	\N	\N	\N	MULANUR, Tamilnadu, z:638106	{}	\N	\N	\N	1	MULANUR, Tamilnadu, z:638106
261	K Karthic	saisreeenterprises2017@gmail.com	p:+919443777668	\N	2	1	\N	{"zip": "z:609001", "city": "Mayiladuthurai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 213, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1254828816232484", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:58.166627+00	2026-04-17 08:02:24.012731+00	warm	0.00	\N	\N	\N	\N	Mayiladuthurai, Tamil Nadu, z:609001	{}	\N	\N	\N	1	Mayiladuthurai, Tamil Nadu, z:609001
359	svs manian	skn5602@gmail.com	p:+918667012573	\N	2	1	\N	{"zip": "z:", "city": "coimbatore", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 248, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1741274657051690", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-17 07:00:14.624618+00	2026-04-17 08:02:32.667986+00	warm	0.00	\N	\N	\N	\N	coimbatore, tamilnadu, z:	{}	\N	\N	\N	1	\N
274	Muthu Palani	pvtoolsindustries@gmail.com	p:+919442649087	\N	2	1	\N	{"zip": "z:606604", "city": "TIRUVANNAMALAI", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 226, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:963925226609177", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:01.115612+00	2026-04-17 08:02:27.267034+00	warm	0.00	\N	\N	\N	\N	TIRUVANNAMALAI, tamilnadu, z:606604	{}	\N	\N	\N	1	TIRUVANNAMALAI, tamilnadu, z:606604
340	Sathish Kumar	kumarsathishm1994@mail.com	p:+918098216685	\N	9	1	\N	{"zip": "z:", "city": "Tiruchirappalli", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 241, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1627322055211858", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 14:30:12.813132+00	2026-04-17 08:02:30.955473+00	warm	0.00	\N	\N	\N	\N	Tiruchirappalli, z:	{}	\N	\N	\N	1	Tiruchirappalli, z:
338	Suresh Suresh	sureshbalu018@gmail.com	p:+919444063329	\N	2	1	\N	{"zip": "z:600032", "city": "Chennai", "state": "TN", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 240, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:838754371878915", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 14:10:12.289405+00	2026-04-17 08:02:30.711229+00	warm	0.00	\N	\N	\N	\N	Chennai, TN, z:600032	{}	\N	\N	\N	1	Chennai, TN, z:600032
276	Navin	na4vin@gmail.com	p:+918122918985	\N	9	1	\N	{"zip": "z:641035", "city": "Coimbatore", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 228, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:896999636673756", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:01.569479+00	2026-04-17 08:02:27.756514+00	warm	0.00	\N	\N	\N	\N	Coimbatore, Tamil Nadu, z:641035	{}	\N	\N	\N	1	Coimbatore, Tamil Nadu, z:641035
277	Arumuga Ramesh Sanmugasundaram	arumugaramesh19@gmail.com	p:+917397256938	\N	2	1	\N	{"zip": "z:7397256938", "city": "chennai city", "state": "tamilnadu chennai", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 229, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:894992433543650", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:01.796103+00	2026-04-17 08:02:28.004746+00	warm	0.00	\N	\N	\N	\N	chennai city, tamilnadu chennai, z:7397256938	{}	\N	\N	\N	1	chennai city, tamilnadu chennai, z:7397256938
270	Mohammed Kajjali	kaseempaints@gmail.com	p:+919994493151	\N	9	1	\N	{"zip": "z:", "city": "Pondicherry", "state": "605602", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 222, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2129977077407231", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:00.208662+00	2026-04-17 08:02:26.269322+00	warm	0.00	\N	\N	\N	\N	Pondicherry, 605602, z:	{}	\N	\N	\N	1	Pondicherry, 605602, z:
283	Rajalingam. K	Commedy129@gmail.com	p:+919443060348	\N	2	1	\N	{"zip": "z:638111", "city": "Tirupur", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 235, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1728138671929553", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:03.157182+00	2026-04-17 08:02:29.481574+00	warm	0.00	\N	\N	\N	\N	Tirupur, Tamil Nadu, z:638111	{}	\N	\N	\N	1	Tirupur, Tamil Nadu, z:638111
358	Seena Vas	srinivasannpt@gmail.com	p:+918148085995	\N	2	1	\N	{"zip": "z:635803", "city": "vellore", "state": "tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 247, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:921463350726263", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-17 06:10:28.953687+00	2026-04-17 08:02:32.424123+00	warm	0.00	\N	\N	\N	\N	vellore, tamil nadu, z:635803	{}	\N	\N	\N	1	\N
355	Karthik	Karthik7085@gnail.com	p:+918056644945	\N	9	2	\N	{"zip": "z:603103", "city": "Chennai", "state": "India", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 245, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:956064466781395", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-16 15:40:13.638685+00	2026-04-18 05:24:57.085369+00	warm	0.00	\N	\N	\N	\N	Chennai, India, z:603103	{}	\N	\N	Manhole	1	\N
269	Athiya Man	athiyaman972@gmail.com	p:+919047044299	\N	2	1	\N	{"zip": "z:", "city": "theni", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 221, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1476611994251847", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:59.981927+00	2026-04-17 08:02:26.023389+00	warm	0.00	\N	\N	\N	\N	theni, tamilnadu, z:	{}	\N	\N	\N	1	theni, tamilnadu, z:
273	Ashok Kumar Karthik	ashokkumar.k24@gmail.com	p:+919944078945	\N	2	1	\N	{"zip": "z:602106", "city": "sriperumbdhur", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 225, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1325607509626600", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:00.888746+00	2026-04-17 08:02:27.022571+00	warm	0.00	\N	\N	\N	\N	sriperumbdhur, tamilnadu, z:602106	{}	\N	\N	\N	1	sriperumbdhur, tamilnadu, z:602106
275	???????????????.....	sathishsathishraj468@gmail.com	p:+919080110468	\N	9	1	\N	{"zip": "z:643001", "city": "Ooty", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 227, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:26315271118084061", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:01.342976+00	2026-04-17 08:02:27.51187+00	warm	0.00	\N	\N	\N	\N	Ooty, Tamilnadu, z:643001	{}	\N	\N	\N	1	Ooty, Tamilnadu, z:643001
317	Manoj kumar	manojsteel.tnp@gmail.com	919994488447	\N	9	1	\N	{"zip": "638506", "city": "Erode", "state": "TN", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 32, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1345038994125083", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:40.542619+00	2026-05-17 13:20:02.988135+00	warm	0.00	\N	\N	\N	\N	Erode, TN, 638506	{}	\N	\N	\N	1	Erode, TN, 638506
401	Venkadesh Palanisamy	venkadeshpalanisamy13@gmail.com	p:+917502934936	\N	9	1	\N	{"zip": "z:639201", "city": "Pollachi", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 265, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2654154558303324", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-02 13:40:05.496481+00	2026-05-17 13:20:04.443819+00	warm	0.00	\N	\N	\N	\N	Pollachi, Tamilnadu, z:639201	{}	\N	\N	\N	1	\N
417	Baskar Palanivel	pbaskar1959@gmail.com	p:+919840903060	\N	9	1	\N	{"zip": "z:600001", "city": "Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 279, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1480049426925862", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-06 14:10:03.955961+00	2026-05-17 13:20:04.516803+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil Nadu, z:600001	{}	\N	\N	\N	1	\N
353	Sakunthala Srinivasan	sakunthala.ramalingam@gmail.com	p:+919944403399	\N	2	10	16	{"zip": "z:", "city": "salem", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 244, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1664510777894894", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-15 14:50:13.577524+00	2026-04-21 06:14:28.243307+00	warm	0.00	\N	\N	\N	\N	salem, tamilnadu, z:	{}	\N	\N	Manhole	1	salem, tamilnadu, z:
347	Arun Kumar	Arunkumar87.m@gmail.com	p:+919941462284	\N	2	1	16	{"zip": "z:", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 85, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1475273850631389", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-15 05:00:23.794951+00	2026-05-17 13:20:01.711658+00	cold	0.00	\N	\N	\N	\N	Chennai, tamilnadu, z:	{}	\N	\N	\N	1	Chennai, tamilnadu, z:
304	Govindarajan Narasingam	ngovind2460@gmail.com	p:+919894257497	\N	2	1	\N	{"zip": "z:605009", "city": "Puduvai", "state": "puducherry 605009", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 74, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1396857198877287", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:49.717141+00	2026-05-17 13:20:01.659224+00	warm	0.00	\N	\N	\N	\N	Puduvai, puducherry 605009, z:605009	{}	\N	\N	\N	1	Puduvai, puducherry 605009, z:605009
279	Sathik Bacha	batha202@gmail.com	p:+919842137866	\N	2	1	\N	{"zip": "z:624001", "city": "Dindigul", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 231, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4393547037560134", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:02.249753+00	2026-04-17 08:02:28.497303+00	warm	0.00	\N	\N	\N	\N	Dindigul, z:624001	{}	\N	\N	\N	1	Dindigul, z:624001
278	Ganeshan Gs	ganeshangs438@gmail.com	p:+919360389645	\N	9	1	\N	{"zip": "z:", "city": "Madurai", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 230, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1483464413147532", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:02.022941+00	2026-04-17 08:02:28.252899+00	warm	0.00	\N	\N	\N	\N	Madurai, z:	{}	\N	\N	\N	1	Madurai, z:
284	Ae.Ramalingam	ramalingamaeit5175@gmail.com	p:+919443624910	\N	2	1	\N	{"zip": "z:", "city": "tiruvannamalai", "state": "tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 236, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1500105934872825", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:03.38353+00	2026-04-17 08:02:29.725972+00	warm	0.00	\N	\N	\N	\N	tiruvannamalai, tamil nadu, z:	{}	\N	\N	\N	1	tiruvannamalai, tamil nadu, z:
266	Sunjaiy Venkat Ramasubramoniam	sunjaiyvenkat@gmail.com	p:+918925334224	\N	2	1	\N	{"zip": "z:629001", "city": "Nagercoil", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 218, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2374249406412753", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:59.301445+00	2026-04-17 08:02:25.286633+00	warm	0.00	\N	\N	\N	\N	Nagercoil, tamilnadu, z:629001	{}	\N	\N	\N	1	Nagercoil, tamilnadu, z:629001
271	saamy	ghspaithamparai@gmail.com	p:+917373735541	\N	2	1	\N	{"zip": "z:621211", "city": "Musiri", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 223, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1285505960194456", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:00.435726+00	2026-04-17 08:02:26.518407+00	warm	0.00	\N	\N	\N	\N	Musiri, tamilnadu, z:621211	{}	\N	\N	\N	1	Musiri, tamilnadu, z:621211
356	Thava Selvan	thavaselva69@gmail.com	p:+918879277998	\N	2	1	\N	{"zip": "z:607801", "city": "chennai", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 246, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4179238342339373", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-16 16:00:17.531127+00	2026-04-17 08:02:32.179984+00	warm	0.00	\N	\N	\N	\N	chennai, Tamilnadu, z:607801	{}	\N	\N	\N	1	\N
333	Iyya Ppan	lakshmielectricalshardwares23@gmail.com	p:+918124429424	\N	9	1	\N	{"zip": "z:606702", "city": "Tiruvannamalai", "state": "Tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 48, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1860741598647737", "google_sheet_config_id": "9"}	waiting for customers reply	t	2026-04-13 07:57:44.620569+00	2026-05-17 13:20:03.145852+00	warm	20.00	B2C	\N	\N	\N	Tiruvannamalai, Tamilnadu, z:606702	{}	15	\N	\N	1	Tiruvannamalai, Tamilnadu, z:606702
303	Manoj Simon	manojkumarsimon06@gmail.com	p:+918838208004	\N	9	1	\N	{"zip": "z:600107", "city": "Chennai", "state": null, "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 73, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2055456822019232", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:49.476988+00	2026-05-17 13:20:01.654824+00	warm	0.00	\N	\N	\N	\N	Chennai, z:600107	{}	\N	\N	\N	1	Chennai, z:600107
337	R SANJAY ( SRK CONSTRUCTION  )	sanjaysa@gmail.com	p:+919282425260	\N	2	1	\N	{"zip": "z:600049", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 52, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1301817645142107", "google_sheet_config_id": "9"}	Imported from Google Sheet	t	2026-04-13 13:50:29.733658+00	2026-05-17 13:20:03.202556+00	warm	0.00	\N	\N	\N	\N	Chennai, tamilnadu, z:600049	{}	\N	\N	\N	1	Chennai, tamilnadu, z:600049
364	SRI KARTHIK ENTERPRISES	srikarthikenterprisess@gmail.com	9944663674	\N	2	8	15	\N	customer want to manhole	t	2026-04-17 07:46:58.70052+00	2026-04-22 05:49:49.454584+00	hot	5.00	B2B	\N	12000.00	\N	No - 27 /1051 Sri Ram Nagar, First Street, Ellichathiram Road, Vazhudhareddy and post Villupuram,\nTAMILNADU - 605401.MOBILE - 9944663674, 9843430086.GSTIN - 33ACNFS4904N1ZO.	{}	\N	15	Manhole	1	RELIANCE BP MOBILITY LIMITED \nRELIANCE PETROL BUNK \nPONNIYAMMANMEDU \nMADHAVARAM ROUNDANA NEAR\nREDHILLS \nCHENNAI.600052
368	Seena Vas	srinivasannpt@gmail.com	p:+918148085995	\N	2	1	\N	{"zip": "z:635803", "city": "vellore", "state": "tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 247, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:921463350726263", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-17 08:04:50.715069+00	2026-05-17 13:20:04.372291+00	warm	0.00	\N	\N	\N	\N	vellore, tamil nadu, z:635803	{}	\N	\N	\N	1	\N
341	Mohamed Shabirsha	shabinsw@gmail.com	p:+919952236637	\N	2	1	\N	{"zip": "z:641603", "city": "avinachi", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 82, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2183018295806734", "google_sheet_config_id": "8"}	Imported from Google Sheet	t	2026-04-13 14:30:25.144579+00	2026-05-17 13:20:01.700037+00	warm	0.00	\N	\N	\N	\N	avinachi, Tamilnadu, z:641603	{}	\N	\N	\N	1	avinachi, Tamilnadu, z:641603
311	KATHIRVEL	kathirvel0898@gmail.com	p:+919688491588	\N	9	1	\N	{"zip": "z:", "city": "Tirupathur", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 81, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1613989376537154", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:51.395975+00	2026-05-17 13:20:01.696197+00	warm	0.00	\N	\N	\N	\N	Tirupathur, Tamilnadu, z:	{}	\N	\N	\N	1	Tirupathur, Tamilnadu, z:
371	Anwar Basha	\N	p:+917339677694	\N	2	1	\N	{"zip": "z:", "city": "tuticorin", "state": "tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 249, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:841492658959926", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-17 08:04:52.996771+00	2026-05-17 13:20:04.379839+00	warm	0.00	\N	\N	\N	\N	tuticorin, tamil nadu, z:	{}	\N	\N	\N	1	\N
267	Anand Kumar	Rakshalaksha@gmail.com	p:+919443049061	\N	2	1	\N	{"zip": "z:643001", "city": "Ooty", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 219, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1331201105508213", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:59.528565+00	2026-04-17 08:02:25.531592+00	warm	0.00	\N	\N	\N	\N	Ooty, tamilnadu, z:643001	{}	\N	\N	\N	1	Ooty, tamilnadu, z:643001
282	Appu Murugan Vel Murugan	appustudio88@gmail.com	p:+919788753938	\N	2	1	\N	{"zip": "z:627002", "city": "Tirunelveli", "state": "super", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 234, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4400673900165196", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:02.930177+00	2026-04-17 08:02:29.234367+00	warm	0.00	\N	\N	\N	\N	Tirunelveli, super, z:627002	{}	\N	\N	\N	1	Tirunelveli, super, z:627002
294	Uma Kathir	kathiruma034@gmail.com	p:+919442557254	\N	2	1	\N	{"zip": "z:641104", "city": "Karamadai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 64, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:3139462739574753", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:47.318277+00	2026-05-17 13:20:01.613945+00	warm	0.00	\N	\N	\N	\N	Karamadai, Tamil Nadu, z:641104	{}	\N	\N	\N	1	Karamadai, Tamil Nadu, z:641104
402	GOWTHAMAN	sureshnhss@yahoo.com	p:+919842539823	\N	2	1	\N	{"zip": "z:614001", "city": "MANNARGUDI", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 266, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1614110709674965", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-03 05:40:05.210642+00	2026-05-17 13:20:04.448619+00	warm	0.00	\N	\N	\N	\N	MANNARGUDI, tamilnadu, z:614001	{}	\N	\N	\N	1	\N
298	Aaj	amanulla@yahoo.com	p:+917550377172	\N	2	1	\N	{"zip": "z:14", "city": "Fujairah", "state": "Fujairah", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 68, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1715910219771466", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:48.277644+00	2026-05-17 13:20:01.631401+00	warm	0.00	\N	\N	\N	\N	Fujairah, Fujairah, z:14	{}	\N	\N	\N	1	Fujairah, Fujairah, z:14
418	O.N.பாஸ்	bossdevi2367@gmail.com	p:+919150025097	\N	2	1	\N	{"zip": "z:", "city": "Batlgundu Dindugal DT", "state": "yes", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 280, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1942231289992325", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-06 16:10:03.826362+00	2026-05-17 13:20:04.520835+00	warm	0.00	\N	\N	\N	\N	Batlgundu Dindugal DT, yes, z:	{}	\N	\N	\N	1	\N
292	Yuvaraj Raj	yuvashd@gmail.com	p:+918056052175	\N	9	1	\N	{"zip": "z:600118", "city": "Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 62, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:34665951869715628", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:46.838361+00	2026-05-17 13:20:01.60617+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil Nadu, z:600118	{}	\N	\N	\N	1	Chennai, Tamil Nadu, z:600118
339	Guru Bhoopthi	gurubhoopathi1981@gmail.com	p:+919043424113	\N	2	1	\N	{"zip": "z:636003", "city": "Salem", "state": "Tamil Nadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 53, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1244108704377661", "google_sheet_config_id": "9"}	Imported from Google Sheet	t	2026-04-13 14:10:28.114808+00	2026-05-17 13:20:03.208717+00	warm	0.00	\N	\N	\N	\N	Salem, Tamil Nadu, z:636003	{}	\N	\N	\N	1	Salem, Tamil Nadu, z:636003
334	Chandru Marappan	chandrumarappan@gmail.com	p:+919842322565	\N	2	1	\N	{"zip": "z:641666", "city": "Tiruppur", "state": "Tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 49, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:823107543590689", "google_sheet_config_id": "9"}	Imported from Google Sheet	t	2026-04-13 07:57:44.852951+00	2026-05-17 13:20:03.15398+00	warm	0.00	\N	\N	\N	\N	Tiruppur, Tamilnadu, z:641666	{}	15	\N	\N	1	Tiruppur, Tamilnadu, z:641666
367	Thava Selvan	thavaselva69@gmail.com	p:+918879277998	\N	2	1	\N	{"zip": "z:607801", "city": "chennai", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 246, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4179238342339373", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-17 08:04:49.574124+00	2026-05-17 13:20:04.367764+00	warm	0.00	\N	\N	\N	\N	chennai, Tamilnadu, z:607801	{}	\N	\N	\N	1	\N
370	svs manian	skn5602@gmail.com	p:+918667012573	\N	2	1	\N	{"zip": "z:", "city": "coimbatore", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 248, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1741274657051690", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-17 08:04:51.855195+00	2026-05-17 13:20:04.37592+00	warm	0.00	\N	\N	\N	\N	coimbatore, tamilnadu, z:	{}	\N	\N	\N	1	\N
306	M Ravikumar	\N	p:+918300123006	\N	2	1	\N	{"zip": "z:627102", "city": "Vallioor", "state": "thamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 76, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1269845281938747", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:50.196544+00	2026-05-17 13:20:01.668278+00	warm	0.00	\N	\N	\N	\N	Vallioor, thamilnadu, z:627102	{}	\N	\N	\N	1	Vallioor, thamilnadu, z:627102
318	Baskaran Chendur	baskaran2705640@gmail.com	919442613242	\N	9	1	\N	{"zip": "625018", "city": "Madurai", "state": "TN", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 33, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "775302352109963", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:40.786922+00	2026-05-17 13:20:02.993377+00	warm	0.00	\N	\N	\N	\N	Madurai, TN, 625018	{}	\N	\N	\N	1	Madurai, TN, 625018
307	Arulmoorthy Mittaminnal	era.1970salem@gmail.com	p:+918940000153	\N	2	1	\N	{"zip": "z:636016", "city": "Salem", "state": "tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 77, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1411076730822459", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:50.436294+00	2026-05-17 13:20:01.6726+00	warm	0.00	\N	\N	\N	\N	Salem, tamilnadu, z:636016	{}	\N	\N	\N	1	Salem, tamilnadu, z:636016
280	Muthu Balaji	balajir173@gmail.com	p:+919003314502	\N	2	1	\N	{"zip": "z:613007", "city": "Thanjavur", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 232, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1475300154303378", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:02.47631+00	2026-04-17 08:02:28.741833+00	warm	0.00	\N	\N	\N	\N	Thanjavur, z:613007	{}	\N	\N	\N	1	Thanjavur, z:613007
319	Felix Lins	feliximman3@gmail.com	919047066800	\N	9	1	\N	{"zip": "627007", "city": "Tirunelveli", "state": "India", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 34, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1732607374779659", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:41.031439+00	2026-05-17 13:20:02.999853+00	warm	0.00	\N	\N	\N	\N	Tirunelveli, India, 627007	{}	\N	\N	\N	1	Tirunelveli, India, 627007
297	Swaminathan Viswanathan	\N	p:+919976214399	\N	2	1	\N	{"zip": "z:614018", "city": "Mannargudi", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 67, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:935282459389661", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:48.037646+00	2026-05-17 13:20:01.627373+00	warm	0.00	\N	\N	\N	\N	Mannargudi, Tamilnadu, z:614018	{}	\N	\N	\N	1	Mannargudi, Tamilnadu, z:614018
301	Pradhaph Jayaraman	pradhaphjp@gmail.com	p:+919444839944	\N	9	1	\N	{"zip": "z:636117", "city": "Salem", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 71, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1884983658851553", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:48.996722+00	2026-05-17 13:20:01.646596+00	warm	0.00	\N	\N	\N	\N	Salem, Tamilnadu, z:636117	{}	\N	\N	\N	1	Salem, Tamilnadu, z:636117
320	Pugazenthi	pugazenthi.maran@gmail.com	916383031323	\N	9	1	\N	{"zip": "636010", "city": "Hai", "state": "Tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 35, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "26015757181439524", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:41.276168+00	2026-05-17 13:20:03.004855+00	warm	0.00	\N	\N	\N	\N	Hai, Tamilnadu, 636010	{}	\N	\N	\N	1	Hai, Tamilnadu, 636010
295	Sabareesh	l.sabareesh@gmail.com	p:+919843746737	\N	2	1	\N	{"zip": "z:642004", "city": "Pollachi", "state": "tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 65, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1468127264776748", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:47.5581+00	2026-05-17 13:20:01.618324+00	warm	0.00	\N	\N	\N	\N	Pollachi, tamilnadu, z:642004	{}	\N	\N	\N	1	Pollachi, tamilnadu, z:642004
327	Mohan prasath msd	mohanprasathdhoni0595@gmail.com	918144956400	\N	9	1	\N	{"zip": null, "city": "Chennai", "state": "India", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 42, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "4015828712050516", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:43.226114+00	2026-05-17 13:20:03.088395+00	warm	0.00	\N	\N	\N	\N	Chennai, India	{}	\N	\N	\N	1	Chennai, India
300	Thilakkannan	kannanthilak14@gmail.com	p:+919787955699	\N	2	1	\N	{"zip": "z:60066", "city": "Chennai", "state": null, "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 70, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:962738599611235", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:48.756962+00	2026-05-17 13:20:01.640565+00	warm	0.00	\N	\N	\N	\N	Chennai, z:60066	{}	\N	\N	\N	1	Chennai, z:60066
313	Amalan Arockyam	\N	917904683232	\N	2	1	\N	{"zip": "625007", "city": "Madurai", "state": "Tamil Nadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 28, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1841187449907384", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:39.562451+00	2026-05-17 13:20:02.968639+00	warm	0.00	\N	\N	\N	\N	Madurai, Tamil Nadu, 625007	{}	\N	\N	\N	1	Madurai, Tamil Nadu, 625007
305	CHANDRASEKAR	sriannaielectricals3@gmail.com	p:+919677417100	\N	2	1	\N	{"zip": "z:625529", "city": "Madurai usilampatti", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 75, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:951316677520594", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:49.956788+00	2026-05-17 13:20:01.663998+00	warm	0.00	\N	\N	\N	\N	Madurai usilampatti, Tamilnadu, z:625529	{}	\N	\N	\N	1	Madurai usilampatti, Tamilnadu, z:625529
324	Ragu Rajeev	v.ragu44@gmail.com	918072090881	\N	9	1	\N	{"zip": "600044", "city": "Chennai", "state": null, "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 39, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "948844807502854", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:42.527574+00	2026-05-17 13:20:03.041665+00	warm	0.00	\N	\N	\N	\N	Chennai, 600044	{}	\N	\N	\N	1	Chennai, 600044
296	jalal s	jalal98sm@gmail.com	p:+918124082359	\N	2	1	\N	{"zip": "z:600001", "city": "Chennai", "state": "TAMILNADU", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 66, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1433190671371061", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:47.797837+00	2026-05-17 13:20:01.623331+00	warm	0.00	\N	\N	\N	\N	Chennai, TAMILNADU, z:600001	{}	\N	\N	\N	1	Chennai, TAMILNADU, z:600001
329	Gurunathan Sargunaraj	sgurunathan06@gmail.com	919994603012	\N	2	1	\N	{"zip": null, "city": "sankarankovil", "state": "tamiladu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 44, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "850436178071171", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:43.690991+00	2026-05-17 13:20:03.114193+00	warm	0.00	\N	\N	\N	\N	sankarankovil, tamiladu	{}	\N	\N	\N	1	sankarankovil, tamiladu
349	Madurai Nk Mari	nnvks1980@gmail.com	p:+917373710044	\N	2	1	\N	{"zip": "z:", "city": "Madurai", "state": "tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 55, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:925315537200244", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-15 06:10:32.571675+00	2026-05-17 13:20:03.216669+00	cold	0.00	\N	\N	\N	\N	Madurai, tamilnadu, z:	{}	\N	\N	\N	1	Madurai, tamilnadu, z:
351	RC-CONSTRUCTION,	\N	9444061805	\N	8	8	\N	\N	Customer want tp igloo roof tile 2500 sft	f	2026-04-15 10:16:31.255844+00	2026-04-16 11:32:06.034861+00	hot	0.00	B2B	\N	150000.00	\N	RC-Construction,No-20,anderson road,ayanavaram,chennai,600023.GST:33ABAFR9373G1Z2.	{}	\N	5	Tiles	1	RC-Construction,No-20,anderson road,ayanavaram,chennai,600023.GST:33ABAFR9373G1Z2.
285	Bala Subramanian	balasunramanian0@gmail.com	p:+919444162931	\N	2	1	\N	{"zip": "z:", "city": "Pattukkottai", "state": "TN", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 237, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1267066208912480", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:03.610164+00	2026-04-17 08:02:29.970395+00	warm	0.00	\N	\N	\N	\N	Pattukkottai, TN, z:	{}	\N	\N	\N	1	Pattukkottai, TN, z:
344	Suresh Raj	richlifestylemarketing@gmail.com	p:+919843386814	\N	2	1	16	{"zip": "z:624101", "city": "Batlagundu", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 242, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1398652282028726", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-14 14:10:12.355643+00	2026-04-17 08:02:31.202775+00	warm	0.00	\N	\N	\N	\N	Batlagundu, tamilnadu, z:624101	{}	\N	\N	\N	1	Batlagundu, tamilnadu, z:624101
268	Ramanathan	bakkaym1990@gmail.com	p:+919750096543	\N	2	1	\N	{"zip": "z:12345", "city": "Tamil Nadu", "state": "Ramanathan", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 220, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1664800034830406", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:44:59.755443+00	2026-04-17 08:02:25.779176+00	warm	0.00	\N	\N	\N	\N	Tamil Nadu, Ramanathan, z:12345	{}	\N	\N	\N	1	Tamil Nadu, Ramanathan, z:12345
287	Logu Tamizhan	tamizhan236@gmail.com	p:+919080766188	\N	2	1	\N	{"zip": "z:600012", "city": "Chennai", "state": "i need ve", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 239, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:950070787431537", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:04.063652+00	2026-04-17 08:02:30.466575+00	warm	0.00	\N	\N	\N	\N	Chennai, i need ve, z:600012	{}	\N	\N	\N	1	Chennai, i need ve, z:600012
272	Syed Mohamed Buhari	emeraldbmrmd@gmail.com	p:+918870609423	\N	9	1	\N	{"zip": "z:623504", "city": "Ramnathapuram", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 224, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:803360002386108", "google_sheet_config_id": "7"}	Imported from Google Sheet	f	2026-04-13 07:45:00.661958+00	2026-04-17 08:02:26.777697+00	warm	0.00	\N	\N	\N	\N	Ramnathapuram, Tamil Nadu, z:623504	{}	\N	\N	\N	1	Ramnathapuram, Tamil Nadu, z:623504
323	s k group Suresh	vanithyasuresh@gmail.com	919944542947	\N	2	1	\N	{"zip": "605010", "city": "Pondicherry", "state": "PY", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 38, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "2188354561989747", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:42.295096+00	2026-05-17 13:20:03.035437+00	warm	0.00	\N	\N	\N	\N	Pondicherry, PY, 605010	{}	\N	\N	\N	1	Pondicherry, PY, 605010
331	தயாநித	dhayanithisivaji@gmail.com	p:+919600797102	\N	2	1	\N	{"zip": "z:605601", "city": "villupuram and Pondicherry .Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 46, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1668470681273701", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:44.155899+00	2026-05-17 13:20:03.136442+00	warm	0.00	\N	\N	\N	\N	villupuram and Pondicherry .Chennai, Tamil Nadu, z:605601	{}	\N	\N	\N	1	villupuram and Pondicherry .Chennai, Tamil Nadu, z:605601
342	Yuvaraj Rubini	youvaraj.ms@gmail.com	p:+918939355466	\N	2	1	16	{"zip": "z:600097", "city": "Chennai", "state": "TN", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 83, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:34692976480345925", "google_sheet_config_id": "8"}	Imported from Google Sheet	t	2026-04-14 05:40:23.234057+00	2026-05-17 13:20:01.704+00	warm	0.00	\N	\N	\N	\N	Chennai, TN, z:600097	{}	16	\N	\N	1	Chennai, TN, z:600097
432	Ahamed Mohamed Ali	anmalianmali@yahoo.co.in	p:+919840573475	\N	2	1	\N	{"zip": "z:", "city": "chennai", "state": "tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 95, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2409064069594378", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-09 08:00:01.406077+00	2026-05-17 13:20:01.754257+00	warm	0.00	\N	\N	\N	\N	chennai, tamilnadu, z:	{}	\N	\N	\N	1	\N
314	Anbu Nayak Yadav	anbuyadavanbu@gmail.com	919843508880	\N	2	1	\N	{"zip": null, "city": "Krishnagiri", "state": "tamilnadi", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 29, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1651723849302792", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:39.807902+00	2026-05-17 13:20:02.973356+00	warm	0.00	\N	\N	\N	\N	Krishnagiri, tamilnadi	{}	\N	\N	\N	1	Krishnagiri, tamilnadi
288	Baskar Mani	mbaskar7352@gmail.com	p:+919790767352	\N	2	1	\N	{"zip": "z:600057", "city": "Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 58, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1305803304774385", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:45.878911+00	2026-05-17 13:20:01.589612+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil Nadu, z:600057	{}	\N	\N	\N	1	Chennai, Tamil Nadu, z:600057
321	C.Krishnakumar	krishnakumarchithravel@gmail.com	919442323581	\N	2	1	\N	{"zip": null, "city": "Tuticorin", "state": null, "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 36, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1358910446044292", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:41.598389+00	2026-05-17 13:20:03.010183+00	warm	0.00	\N	\N	\N	\N	Tuticorin	{}	\N	\N	\N	1	Tuticorin
332	praveen	spk@dhivya.ac.in	p:+918006280032	\N	9	1	\N	{"zip": "z:606801", "city": "Chetpet", "state": "india", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 47, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2371434536663255", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:44.388111+00	2026-05-17 13:20:03.141999+00	warm	0.00	\N	\N	\N	\N	Chetpet, india, z:606801	{}	15	\N	\N	1	Chetpet, india, z:606801
293	Poovarasan Varshan	poovarasan1093@gmail.com	p:+917904056155	\N	2	1	\N	{"zip": "z:600122", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 63, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:25492106380465984", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:47.078638+00	2026-05-17 13:20:01.609974+00	warm	0.00	\N	\N	\N	\N	Chennai, tamilnadu, z:600122	{}	\N	\N	\N	1	Chennai, tamilnadu, z:600122
312	Riyaz SR	riyazaslam08@gmail.com	919003609220	\N	2	1	\N	{"zip": "625007", "city": "Madurai", "state": "TAMIL NADU", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 27, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1547616394035662", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:39.317646+00	2026-05-17 13:20:02.963997+00	warm	0.00	\N	\N	\N	\N	Madurai, TAMIL NADU, 625007	{}	\N	\N	\N	1	Madurai, TAMIL NADU, 625007
299	Manoj Ramalingam	r.manojvpm@gmail.com	p:+919789229334	\N	2	1	\N	{"zip": "z:600127", "city": "Chennai", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 69, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:804919132241147", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:48.517459+00	2026-05-17 13:20:01.63629+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamilnadu, z:600127	{}	\N	\N	\N	1	Chennai, Tamilnadu, z:600127
326	Desinghucharulatha Desinghucharulatha	desinghsarulatha@gmail.com	919003968047	\N	2	1	\N	{"zip": "625531", "city": "Vellore", "state": "tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 41, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1265187355178408", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:42.993741+00	2026-05-17 13:20:03.06932+00	warm	0.00	\N	\N	\N	\N	Vellore, tamilnadu, 625531	{}	\N	\N	\N	1	Vellore, tamilnadu, 625531
330	Arumuga Ramesh Sanmugasundaram	arumugaramesh19@gmail.com	917397256938	\N	2	1	\N	{"zip": "7397256938", "city": "chennai city", "state": "tamilnadu chennai", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 45, "sheet_source_raw": "fb", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "1632932041373203", "google_sheet_config_id": "9"}	Imported from Google Sheet	t	2026-04-13 07:57:43.923398+00	2026-05-17 13:20:03.129518+00	warm	0.00	\N	\N	\N	\N	chennai city, tamilnadu chennai, 7397256938	{}	\N	\N	\N	1	chennai city, tamilnadu chennai, 7397256938
302	Praveen Kumar Mahendran	praveenmechengg33@gmail.com	p:+919962499175	\N	9	1	\N	{"zip": "z:600021", "city": "Chennai", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 72, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1645452880019941", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:49.23673+00	2026-05-17 13:20:01.650453+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamilnadu, z:600021	{}	\N	\N	\N	1	Chennai, Tamilnadu, z:600021
289	Moorthy Shanmugam	moorthyabi@gmail.com	p:+919790071818	\N	9	1	\N	{"zip": "z:638011", "city": "Erode", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 59, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1005017358875574", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:46.118722+00	2026-05-17 13:20:01.594984+00	warm	0.00	\N	\N	\N	\N	Erode, Tamil Nadu, z:638011	{}	\N	\N	\N	1	Erode, Tamil Nadu, z:638011
310	Mohamed Faizal Raja	faizalthebuilder@gmail.com	p:+919940613405	\N	9	1	\N	{"zip": "z:600086", "city": "Royapettah", "state": "Chennai", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 80, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2088125501744471", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:51.156099+00	2026-05-17 13:20:01.691499+00	warm	0.00	\N	\N	\N	\N	Royapettah, Chennai, z:600086	{}	\N	\N	\N	1	Royapettah, Chennai, z:600086
375	Suresh Rajendran	sureshr158@gmail.com	p:+919884974505	\N	2	1	\N	{"zip": "z:609503", "city": "Karaikal Nagapattinam", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 251, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1973927643250270", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-17 15:40:28.729964+00	2026-05-17 13:20:04.388131+00	warm	0.00	\N	\N	\N	\N	Karaikal Nagapattinam, tamilnadu, z:609503	{}	\N	\N	Manhole	1	\N
290	Vivek Manesh	vivekmanesh91@gmail.com	p:+918939368401	\N	9	1	\N	{"zip": "z:600056", "city": "Poonamallee", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 60, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1289667606436074", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-13 07:48:46.358496+00	2026-05-17 13:20:01.598817+00	warm	0.00	\N	\N	\N	\N	Poonamallee, Tamilnadu, z:600056	{}	\N	\N	\N	1	Poonamallee, Tamilnadu, z:600056
389	SRI JAYRAM AGENCIES	\N	9842797995	\N	\N	\N	15	\N	\N	t	2026-04-21 04:28:43.777571+00	2026-04-21 04:47:30.824426+00	warm	0.00	B2Ch	\N	\N	\N	214, Karur Main Road , \nMulanur -638106\nTirupur (DT)\nPho: 9842797995	{}	\N	15	Manhole	1	214, Karur Main Road , \nMulanur -638106\nTirupur (DT)\nPho: 9842797995
393	Santhi Kiruba	kirubasanthi@ymail.com	p:+919487500576	\N	9	1	\N	{"zip": "z:641011", "city": "Coimbatore", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 258, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:27119539574318456", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-22 15:10:04.737777+00	2026-05-17 13:20:04.41588+00	warm	0.00	\N	\N	\N	\N	Coimbatore, Tamilnadu, z:641011	{}	\N	\N	\N	1	\N
386	Manikandan Cl	lmmani684@gmail.com	p:+918220909011	\N	2	1	\N	{"zip": "z:603401", "city": "செங்கற்பட்டு", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 86, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1992366214988300", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-20 11:20:02.514852+00	2026-05-17 13:20:01.71593+00	warm	0.00	\N	\N	\N	\N	செங்கற்பட்டு, Tamilnadu, z:603401	{}	\N	\N	\N	1	\N
390	Mr. Gangatharan	\N	9381031440	\N	8	4	\N	\N	customer want to manhole cover	t	2026-04-21 06:07:38.787595+00	2026-04-21 06:07:46.597353+00	hot	0.00	B2C	\N	\N	\N	Sooriur ,\nTrichy\nPho: 9381031440	{}	\N	5	Manhole	1	Sooriur ,\nTrichy\nPho: 9381031440
397	Jawahar G	agtradersharur@gmail.com	p:+918072717060	\N	9	1	\N	{"zip": "z:636903", "city": "Harur", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 262, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1303208875210878", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-26 14:30:04.203041+00	2026-05-17 13:20:04.431816+00	warm	0.00	\N	\N	\N	\N	Harur, Tamilnadu, z:636903	{}	\N	\N	\N	1	\N
387	Ramesh Babu	sridheepa@gmail.com	p:+919842178804	\N	2	1	\N	{"zip": "z:625012", "city": "Madurai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 87, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:793568840273647", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-04-20 12:30:02.86622+00	2026-05-17 13:20:01.719635+00	warm	0.00	\N	\N	\N	\N	Madurai, Tamil Nadu, z:625012	{}	\N	\N	\N	1	\N
392	Natarajan Subramani	natraj74raj@gmail.com	p:+917904433460	\N	2	1	\N	{"zip": "z:620002", "city": "trichy", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 257, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:988300593537380", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-22 07:20:04.382086+00	2026-05-17 13:20:04.411748+00	warm	0.00	\N	\N	\N	\N	trichy, tamilnadu, z:620002	{}	\N	\N	\N	1	\N
400	Sushil jain	indiaamprime@gmail.com	p:+919094317500	\N	9	1	\N	{"zip": "z:600001", "city": "Chennai", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 264, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:967663802934118", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-02 13:30:03.722987+00	2026-05-17 13:20:04.439739+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamilnadu, z:600001	{}	\N	\N	\N	1	\N
388	S Vijayakumar	vijayakumarsubbiah2010@gmail.com	p:+919489472425	\N	9	1	\N	{"zip": "z:625020", "city": "Madurai 625020", "state": "India", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 255, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:3030682997135323", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-20 12:50:05.400158+00	2026-05-17 13:20:04.404204+00	warm	0.00	\N	\N	\N	\N	Madurai 625020, India, z:625020	{}	\N	\N	\N	1	\N
399	Sridhar Janarthanam	jsrbuilders.tvm@gmail.com	p:+919488465855	\N	2	1	\N	{"zip": "z:606601", "city": "Thiruvannamalai,Tamil Nadu,", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 263, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1045787088626014", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-02 13:10:04.783757+00	2026-05-17 13:20:04.435923+00	warm	0.00	\N	\N	\N	\N	Thiruvannamalai,Tamil Nadu,, Tamil Nadu, z:606601	{}	\N	\N	\N	1	\N
391	paramasivan Ramaiah	civayanama@gmail.com	p:+919443810688	\N	2	1	\N	{"zip": "z:600073", "city": "600073", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 256, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1628430408208803", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-21 13:40:03.955991+00	2026-05-17 13:20:04.40827+00	warm	0.00	\N	\N	\N	\N	600073, Tamil Nadu, z:600073	{}	\N	\N	\N	1	\N
398	SREE LORD VENKATACHALAPATHI EDUCATIONAL TRUST,	\N	+91 8800973322	\N	8	3	\N	\N	\N	t	2026-05-02 07:51:37.994636+00	2026-05-02 07:51:43.810631+00	hot	0.00	B2C	\N	\N	\N	TRICHY NAMAKKAL MAIN ROAD, TRICHY, THOTTIAM,TIRUCHIRAPPALLI,621203	{}	\N	5	Kerbstone	1	\N
395	Syed Anszary	anszary@gmail.com	p:+917358665549	\N	9	1	\N	{"zip": "z:600040", "city": "Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 260, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1625799645361103", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-23 15:10:04.761197+00	2026-05-17 13:20:04.423947+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil Nadu, z:600040	{}	\N	\N	\N	1	\N
396	Deenadayalan Kuppa Naidu Gunapushnam	deenaelectsoft@gmail.com	p:+918148100604	\N	2	1	\N	{"zip": "z:602001", "city": "chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 261, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1257104719920145", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-24 12:40:04.145206+00	2026-05-17 13:20:04.428096+00	warm	0.00	\N	\N	\N	\N	chennai, Tamil Nadu, z:602001	{}	\N	\N	\N	1	\N
394	Sridhar P K	sridhars61@gmail.com	p:+919840314752	\N	2	1	\N	{"zip": "z:600095", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 259, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1616908506256615", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-04-23 06:30:03.596723+00	2026-05-17 13:20:04.420015+00	warm	0.00	\N	\N	\N	\N	Chennai, tamilnadu, z:600095	{}	\N	\N	\N	1	\N
416	Akbar Chezhian	akbarchithathur10@gmail.com	p:+919095595271	\N	2	1	\N	{"zip": "z:", "city": "Cheyyar", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 278, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1741911380522419", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-06 13:40:04.141461+00	2026-05-17 13:20:04.511931+00	warm	0.00	\N	\N	\N	\N	Cheyyar, Tamilnadu, z:	{}	\N	\N	\N	1	\N
411	M/s Kuviyam Infra Developers Pvt Ltd	\N	9865057517	M/s Kuviyam Infra Developers Pvt Ltd	\N	\N	15	\N	\N	t	2026-05-05 07:33:20.494084+00	2026-05-05 07:33:33.807742+00	warm	0.00	B2Ch	\N	\N	\N	14, Gandhiji Street, Malaiyappa Nagar\nAriyamangalam, Trichy- 620010	{}	\N	15	Manhole	1	14, Gandhiji Street, Malaiyappa Nagar\nAriyamangalam, Trichy- 620010
407	Sri	KandaswarnaFabric@gmail.com	p:+919443364578	\N	9	1	\N	{"zip": "z:636007", "city": "Salem", "state": "Salem TAMILNADU", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 271, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1604435873977369", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-04 12:10:04.665864+00	2026-05-17 13:20:04.468877+00	warm	0.00	\N	\N	\N	\N	Salem, Salem TAMILNADU, z:636007	{}	\N	\N	\N	1	\N
405	wilson	pothigaibiomass@gmail.com	p:+919344749399	\N	2	1	\N	{"zip": "z:", "city": "Pudukkottai", "state": "TAMILNADU", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 269, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1483385906476909", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-04 12:10:04.513428+00	2026-05-17 13:20:04.460545+00	warm	0.00	\N	\N	\N	\N	Pudukkottai, TAMILNADU, z:	{}	\N	\N	\N	1	\N
409	Uday Kumar	udayk269@gmail.com	p:+919894807318	\N	2	1	\N	{"zip": "z:632602", "city": "GUDIYATHAM", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 273, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1514313816959228", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-04 16:50:06.413046+00	2026-05-17 13:20:04.476643+00	warm	0.00	\N	\N	\N	\N	GUDIYATHAM, tamilnadu, z:632602	{}	\N	\N	\N	1	\N
413	sivasankaran	sivadeva1495@gmail.com	p:+919025530212	\N	9	1	\N	{"zip": "z:606604", "city": "Tiruvannamalai", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 275, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:948988671094996", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-05 13:00:04.750041+00	2026-05-17 13:20:04.484649+00	warm	0.00	\N	\N	\N	\N	Tiruvannamalai, z:606604	{}	\N	\N	\N	1	\N
410	Upendra Traders	\N	9894807318	\N	\N	\N	15	\N	\N	t	2026-05-05 05:15:41.374649+00	2026-05-05 05:27:35.096026+00	warm	0.00	B2Ch	\N	\N	\N	Vellore \nPho: 9894807318	{}	15	5	Manhole	1	Vellore \nPho: 9894807318
433	Sri Ramachandra Traders	SRT04072018@gmail.com	98405 73475	\N	\N	\N	15	\N	\N	t	2026-05-09 09:27:40.830458+00	2026-05-09 09:27:49.872335+00	warm	0.00	B2B	\N	\N	\N	Plot No 20 , Seethapathy Street \nAmirthammal Nagar, Lotus Colony , 01st Sreet\nMadhavaram, Chennai	{}	\N	15	Roof Tiles	1	Plot No 20 , Seethapathy Street \nAmirthammal Nagar, Lotus Colony , 01st Sreet\nMadhavaram, Chennai
412	Dhamodharan p	dhamo.777@gmail.com	p:+918747013356	\N	2	1	\N	{"zip": "z:629802", "city": "nagercoil", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 274, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:983699004038664", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-05 12:20:05.712974+00	2026-05-17 13:20:04.480775+00	warm	0.00	\N	\N	\N	\N	nagercoil, Tamil Nadu, z:629802	{}	\N	\N	\N	1	\N
406	Khan Amjath	k.mamjathkhan007@gmail.com	p:+919894390074	\N	2	1	\N	{"zip": "z:63000", "city": "Kuwait City", "state": "Al Kuwait", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 270, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:3947145345422004", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-04 12:10:04.612695+00	2026-05-17 13:20:04.464872+00	warm	0.00	\N	\N	\N	\N	Kuwait City, Al Kuwait, z:63000	{}	\N	\N	\N	1	\N
414	Mani Gramani	manigramani27@gmail.com	p:+919841620249	\N	2	1	\N	{"zip": "z:600003", "city": "Chennai", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 276, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1695619998356517", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-05 14:00:03.864053+00	2026-05-17 13:20:04.493572+00	warm	0.00	\N	\N	\N	\N	Chennai, z:600003	{}	\N	\N	\N	1	\N
404	Mohideen Khaja	mhuniversalkhaja@gmail.com	p:+919840271786	\N	2	1	\N	{"zip": "z:600013", "city": "thenkasi", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 268, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1914484639269633", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-03 08:40:04.915528+00	2026-05-17 13:20:04.456737+00	warm	0.00	\N	\N	\N	\N	thenkasi, tamilnadu, z:600013	{}	\N	\N	\N	1	\N
415	Suriya Prakash	surinarenrabi@yahoo.com	p:+919944971917	\N	2	1	\N	{"zip": "z:635109", "city": "Hosur", "state": "Tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 277, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1016340547392555", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-06 13:40:04.118749+00	2026-05-17 13:20:04.499645+00	warm	0.00	\N	\N	\N	\N	Hosur, Tamil nadu, z:635109	{}	\N	\N	\N	1	\N
403	K M G Surendran	surendrankmg@gmail.com	p:+919677782230	\N	2	1	\N	{"zip": "z:638183", "city": "komarapalayam", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 267, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:3102168643322632", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-03 07:00:04.376132+00	2026-05-17 13:20:04.452925+00	warm	0.00	\N	\N	\N	\N	komarapalayam, z:638183	{}	\N	\N	\N	1	\N
419	O.N.Boss	bossdevi2367@gmail.com	9150025097	\N	\N	\N	16	\N	\N	t	2026-05-07 04:15:29.533863+00	2026-05-07 04:15:38.802048+00	warm	0.00	\N	\N	\N	\N	Batlgundu \nDindugal	{}	\N	15	Manhole	1	Batlgundu \nDindugal
408	Dhanasekar K	sekardk2015@gmail.com	p:+917358493610	\N	2	1	\N	{"zip": "z:", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 272, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2202025977226975", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-04 12:10:04.743499+00	2026-05-17 13:20:04.472767+00	warm	0.00	\N	\N	\N	\N	Chennai, tamilnadu, z:	{}	\N	\N	\N	1	\N
423	Felix Lins	feliximman3@gmail.com	p:+919047066800	\N	9	1	\N	{"zip": "z:627007", "city": "Tirunelveli", "state": "India", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 281, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1015356494155814", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-08 04:50:04.672045+00	2026-05-17 13:20:04.529838+00	warm	0.00	\N	\N	\N	\N	Tirunelveli, India, z:627007	{}	\N	\N	\N	1	\N
420	p c Muralee	padhukrish79@yahoo.com	p:+919884000113	\N	2	1	\N	{"zip": "z:", "city": "Chennai", "state": "tamil nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 88, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:936485159381807", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-07 13:10:03.221674+00	2026-05-17 13:20:01.723539+00	warm	0.00	\N	\N	\N	\N	Chennai, tamil nadu, z:	{}	\N	\N	\N	1	\N
424	Jegatheesan ple send pr list catlJega	Chennaimahalakshmi@gmail.com	p:+919840070822	\N	2	1	\N	{"zip": "z:600106", "city": "Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 282, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:974195881647128", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-08 10:10:04.251674+00	2026-05-17 13:20:04.535766+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil Nadu, z:600106	{}	\N	\N	\N	1	\N
428	Suresh Natraj Suresh	pdotgexpressassociation@gmail.com	p:+919566011505	\N	2	1	\N	{"zip": "z:600069", "city": "Chennai", "state": "Tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 283, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1977188692881872", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-08 13:20:03.442269+00	2026-05-17 13:20:04.540146+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil nadu, z:600069	{}	\N	\N	\N	1	\N
422	M Muthusamy	muthusamy660077@gmail.com	p:+919943552798	\N	2	1	\N	{"zip": "z:04566", "city": "mathurai", "state": "தமிழ்நாடு", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 90, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1304858701596431", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-07 13:50:01.113079+00	2026-05-17 13:20:01.73339+00	warm	0.00	\N	\N	\N	\N	mathurai, தமிழ்நாடு, z:04566	{}	\N	\N	\N	1	\N
429	Aroon	coolcoooll@gmail.com	p:+919952000051	\N	9	1	\N	{"zip": "z:600013", "city": "Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 284, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1000993209123646", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-08 13:30:05.091974+00	2026-05-17 13:20:04.545408+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil Nadu, z:600013	{}	\N	\N	\N	1	\N
343	Mani Barathi	gishalborre6@hotmail.com	p:+918667390581	\N	9	1	16	{"zip": "z:606705", "city": "Thiruvannamalai", "state": "India", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 84, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2419277898539313", "google_sheet_config_id": "8"}	Imported from Google Sheet	t	2026-04-14 05:50:23.516858+00	2026-05-17 13:20:01.707927+00	warm	2.50	B2C	\N	42000.00	\N	Thiruvannamalai, India, z:606705	{}	15	\N	\N	1	Thiruvannamalai, India, z:606705
421	Salai Kuberan	kuberan.bhel@gmail.com	p:+919442503059	\N	9	1	\N	{"zip": "z:620001", "city": "Tiruchirappalli", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 89, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1520764453016615", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-07 13:30:01.286561+00	2026-05-17 13:20:01.727936+00	warm	0.00	\N	\N	\N	\N	Tiruchirappalli, Tamil Nadu, z:620001	{}	\N	\N	\N	1	\N
425	Muralidharan V K	muraliji1957@gmail.com	p:+919840439821	\N	2	1	\N	{"zip": "z:", "city": "Chennai,Mugalivakkam", "state": "tamil nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 91, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2038318356716976", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-08 12:50:01.098759+00	2026-05-17 13:20:01.73749+00	warm	0.00	\N	\N	\N	\N	Chennai,Mugalivakkam, tamil nadu, z:	{}	\N	\N	\N	1	\N
427	Paramesh Kumar	\N	p:+919994667020	\N	2	1	\N	{"zip": "z:638004", "city": "Erode", "state": "tamil nadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 56, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1301052601371617", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-05-08 13:20:02.123607+00	2026-05-17 13:20:03.220734+00	warm	0.00	\N	\N	\N	\N	Erode, tamil nadu, z:638004	{}	\N	\N	\N	1	\N
430	Navas Navas	navasdeennavas60@gmail.com	p:+918668009205	\N	9	1	\N	{"zip": "z:612001", "city": "Kumbakonam", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 93, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1524179912399247", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-09 07:40:01.255485+00	2026-05-17 13:20:01.745914+00	warm	0.00	\N	\N	\N	\N	Kumbakonam, Tamil Nadu, z:612001	{}	\N	\N	\N	1	\N
431	gangadharan.k	ammafancefance@gmail.com	p:+919994789084	\N	2	1	\N	{"zip": "z:", "city": "Tiruvannamalai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 94, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2118704765640061", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-09 07:40:01.282897+00	2026-05-17 13:20:01.749971+00	warm	0.00	\N	\N	\N	\N	Tiruvannamalai, Tamil Nadu, z:	{}	\N	\N	\N	1	\N
316	Muthu Kumar T	muthukumarmadurai007@gmail.com	919363635331	\N	9	1	\N	{"zip": "625014", "city": "Madurai", "state": "Tamilnadu", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 31, "sheet_source_raw": "ig", "sheet_sales_person": "FALSE", "google_sheet_lead_id": "25806391345707508", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-04-13 07:57:40.297922+00	2026-05-17 13:20:02.983656+00	warm	0.00	\N	\N	\N	\N	Madurai, Tamilnadu, 625014	{}	\N	\N	\N	1	Madurai, Tamilnadu, 625014
426	Baskar Narayanan	\N	p:+919500956456	\N	2	1	\N	{"zip": "z:638002", "city": "Erode", "state": "tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 92, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1143040165555270", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-08 13:20:01.068864+00	2026-05-17 13:20:01.741576+00	warm	0.00	\N	\N	\N	\N	Erode, tamilnadu, z:638002	{}	\N	\N	\N	1	\N
438	Vengatesh N	vengateshandco@gmail.com	p:+919842254660	\N	9	1	\N	{"zip": "z:", "city": "Coimbatore", "state": "Coimbatore", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 287, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1566137431791871", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-10 14:40:03.959333+00	2026-05-17 13:20:04.56315+00	warm	0.00	\N	\N	\N	\N	Coimbatore, Coimbatore, z:	{}	\N	\N	\N	1	\N
434	Muralikrishna	sssmk28@gmail.com	p:+917358668435	\N	2	1	\N	{"zip": "z:603103", "city": "Chennai", "state": "Tamilnad", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 96, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:985514577382966", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-09 12:40:01.430167+00	2026-05-17 13:20:01.757836+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamilnad, z:603103	{}	\N	\N	\N	1	\N
442	Balakrishnamurthy Murthy	cbalakrishnamurthy@yahoo.com	p:+919894380717	\N	2	1	\N	{"zip": "z:641654", "city": "Avanashi", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 291, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1288701412831994", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-11 12:10:04.431704+00	2026-05-17 13:20:04.652079+00	warm	0.00	\N	\N	\N	\N	Avanashi, Tamil Nadu, z:641654	{}	\N	\N	\N	1	\N
447	Thangavel N	nthangavel1966@gmail.com	p:+919150490490	\N	2	1	\N	{"zip": "z:", "city": "truppur", "state": "tamil nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 98, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4083931978495880", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-13 08:10:01.992997+00	2026-05-17 13:20:01.765636+00	warm	0.00	\N	\N	\N	\N	truppur, tamil nadu, z:	{}	\N	\N	\N	1	\N
439	Mohammed Farooq	mohadfarooq@gmail.com	p:+919626477132	\N	9	1	\N	{"zip": "z:631030", "city": "Coimbatore", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 288, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2913338622348888", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-10 15:00:04.141886+00	2026-05-17 13:20:04.577665+00	warm	0.00	\N	\N	\N	\N	Coimbatore, Tamil Nadu, z:631030	{}	\N	\N	\N	1	\N
445	Rama Krishnan	rku1986@yahoo.com	p:+918122758806	\N	2	1	\N	{"zip": "z:", "city": "dindigul", "state": "TAMIL NADU", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 97, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4554883794834320", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-12 11:20:01.086669+00	2026-05-17 13:20:01.761463+00	warm	0.00	\N	\N	\N	\N	dindigul, TAMIL NADU, z:	{}	\N	\N	\N	1	\N
435	Mohanarangam.E	\N	p:+919514420999	\N	2	1	\N	{"zip": "z:", "city": "Chennai", "state": "9/5 Anna Salai erukkanchery Chennai 600118", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 285, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1410597847778309", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-09 14:20:04.385715+00	2026-05-17 13:20:04.552163+00	warm	0.00	\N	\N	\N	\N	Chennai, 9/5 Anna Salai erukkanchery Chennai 600118, z:	{}	\N	\N	\N	1	\N
436	senthilkumar	idealacademy2008@gmail.com	p:+919842718495	\N	2	1	\N	{"zip": "z:", "city": "salem", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 286, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2826116787746014", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-09 14:40:03.839466+00	2026-05-17 13:20:04.556101+00	warm	0.00	\N	\N	\N	\N	salem, Tamilnadu, z:	{}	\N	\N	\N	1	\N
444	Jayauday ragav	jayauday2401@gmail.com	p:+919698222200	\N	2	1	\N	{"zip": "z:", "city": "nattarampalli", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 293, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2055351582068367", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-12 11:00:03.993383+00	2026-05-17 13:20:04.666429+00	warm	0.00	\N	\N	\N	\N	nattarampalli, Tamilnadu, z:	{}	\N	\N	\N	1	\N
437	Zakir hussain  b	zakirb4traders@gmail.com	p:+919994096400	\N	2	1	\N	{"zip": "z:635802", "city": "Ambur  635802", "state": "Vellore district", "sheet_status": "Igloo Kerbstones", "import_source": "google_sheet", "sheet_row_1based": 57, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4330224647251447", "google_sheet_config_id": "9"}	Imported from Google Sheet	f	2026-05-10 06:10:02.946646+00	2026-05-17 13:20:03.225416+00	warm	0.00	\N	\N	\N	\N	Ambur  635802, Vellore district, z:635802	{}	\N	\N	\N	1	\N
446	Prasath Siva	prasath.sivasubramanian@gmail.com	p:+919486269213	\N	2	1	\N	{"zip": "z:", "city": "Martha dam", "state": "Haryana", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 294, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1598818204525283", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-12 14:20:03.4715+00	2026-05-17 13:20:04.670632+00	warm	0.00	\N	\N	\N	\N	Martha dam, Haryana, z:	{}	\N	\N	\N	1	\N
443	Cbabu Babu	cbabu25061968@gmail.com	p:+917010573604	\N	2	1	\N	{"zip": "z:600087", "city": "Chennai", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 292, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1666725741257915", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-11 12:20:06.610186+00	2026-05-17 13:20:04.657108+00	warm	0.00	\N	\N	\N	\N	Chennai, Tamil Nadu, z:600087	{}	\N	\N	\N	1	\N
453	Martin Bala	kgb.martin@gmail.com	p:+919688613555	\N	2	1	\N	{"zip": "z:627428", "city": "Ambasamuthram", "state": "Tamil Nadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 100, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2259264078146772", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-14 12:40:02.64955+00	2026-05-17 13:20:01.774681+00	warm	0.00	\N	\N	\N	\N	Ambasamuthram, Tamil Nadu, z:627428	{}	\N	\N	\N	1	\N
456	PSN Construction	\N	+91 94433 68659	\N	2	2	\N	\N	\N	t	2026-05-15 11:50:14.111753+00	2026-05-15 12:00:42.283537+00	hot	5.00	B2B	\N	400000.00	\N	72nd Floor, \nJanappachatram, \nKiribati Nagar,\nChennai-67.\nPh:+91 94433 68659	{}	\N	5	Kerbstone	1	PSN Construction, \nVellore.
449	Meenakshi subramanian s.j	meenakshispunpipes84@gmail.com	p:+919176465020	\N	9	1	\N	{"zip": "z:622501", "city": "Pudukottai", "state": "Tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 296, "sheet_source_raw": "ig", "sheet_sales_person": "false", "google_sheet_lead_id": "l:27070683295890343", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-13 13:40:03.284389+00	2026-05-17 13:20:04.683863+00	warm	0.00	\N	\N	\N	\N	Pudukottai, Tamil nadu, z:622501	{}	\N	\N	\N	1	\N
440	ஏ.பி ராஜா	apraja04041970@gmail.com	p:+919842131224	\N	2	1	\N	{"zip": "z:641008", "city": "coimbatore", "state": "Tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 289, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:2159685138128750", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-11 12:00:06.188013+00	2026-05-17 13:20:04.607732+00	warm	0.00	\N	\N	\N	\N	coimbatore, Tamilnadu, z:641008	{}	\N	\N	\N	1	\N
441	Annamalai Kumaravel	annamalai20685@gmail.com	p:+919841411029	\N	2	1	\N	{"zip": "z:600060", "city": "Chennai", "state": "Chennai", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 290, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:4119225145034543", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-11 12:00:06.253741+00	2026-05-17 13:20:04.613186+00	warm	0.00	\N	\N	\N	\N	Chennai, Chennai, z:600060	{}	\N	\N	\N	1	\N
450	Mr. Jayaraj .S	\N	9600162467	\N	\N	\N	15	\N	\N	t	2026-05-14 06:15:00.316137+00	2026-05-14 06:16:07.475183+00	warm	0.00	B2B	\N	\N	\N	NPL Devi #111, 5th Floor ,\nLB Road , Thiruvanmiyur\nChennai  - 41	{}	\N	15	Kerbstone	1	NPL Devi #111, 5th Floor ,\nLB Road , Thiruvanmiyur\nChennai  - 41
451	ஆறு. மகேந்திரன்	a.mahendran1502@gmail.com	p:+919442144404	\N	2	1	\N	{"zip": "z:623707", "city": "Paramakudi", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 297, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:830314906802347", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-14 12:10:03.711854+00	2026-05-17 13:20:04.689691+00	warm	0.00	\N	\N	\N	\N	Paramakudi, tamilnadu, z:623707	{}	\N	\N	\N	1	\N
454	john	vijujohn1976@gmail.com	p:+919444901872	\N	2	1	\N	{"zip": "z:600091", "city": "Chennai", "state": "tamilnadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 298, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1908505013137699", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-14 15:30:12.754611+00	2026-05-17 13:20:04.694656+00	warm	0.00	\N	\N	\N	\N	Chennai, tamilnadu, z:600091	{}	\N	\N	\N	1	\N
452	Nagarajan Shanmugam	\N	p:+918012227898	\N	2	1	\N	{"zip": "z:606604", "city": "Tirruvannamalai", "state": "Tamilnadu", "sheet_status": "Igloo Tile Leads", "import_source": "google_sheet", "sheet_row_1based": 99, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:980417928020963", "google_sheet_config_id": "8"}	Imported from Google Sheet	f	2026-05-14 12:20:03.255679+00	2026-05-17 13:20:01.769663+00	warm	0.00	\N	\N	\N	\N	Tirruvannamalai, Tamilnadu, z:606604	{}	\N	\N	\N	1	\N
448	KL Shanmugam	shrichinnammantex@gmail.com	p:+919865976088	\N	2	1	\N	{"zip": "z:638301", "city": "Bhavani", "state": null, "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 295, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1001245845776646", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-13 13:30:04.220681+00	2026-05-17 13:20:04.675404+00	warm	0.00	\N	\N	\N	\N	Bhavani, z:638301	{}	\N	\N	\N	1	\N
455	Guna Vel	info.smartwatt@gmail.com	p:+919600341644	\N	2	1	\N	{"zip": "z:625001", "city": "Madurai", "state": "tamil nadu", "sheet_status": "Igloo Tile Manhole Leads-copy", "import_source": "google_sheet", "sheet_row_1based": 299, "sheet_source_raw": "fb", "sheet_sales_person": "false", "google_sheet_lead_id": "l:1294267059474651", "google_sheet_config_id": "10"}	Imported from Google Sheet	f	2026-05-15 08:10:04.260462+00	2026-05-17 13:20:04.698687+00	warm	0.00	\N	\N	\N	\N	Madurai, tamil nadu, z:625001	{}	\N	\N	\N	1	\N
\.


--
-- Data for Name: module_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.module_settings (id, module, label, is_enabled, allowed_roles, updated_at, tenant_id) FROM stdin;
7	hr	HR & Payroll	t	{"Super Admin",Admin,HR}	2026-04-09 01:31:33.164101+00	1
6	finance	Finance	t	{"Super Admin",Admin,"Sales Executive",HR}	2026-04-09 03:57:33.438928+00	1
5	production	Production	t	{"Super Admin",Admin,"Sales Executive",HR}	2026-04-13 09:45:19.122996+00	1
1	crm	CRM	t	{"Super Admin",Admin,"Sales Executive",Manager,Agent,Accountant,"Sales Manager"}	2026-04-13 09:53:01.858363+00	1
2	sales	Sales	t	{"Super Admin",Admin,"Sales Executive","Sales Manager"}	2026-04-13 09:53:04.460983+00	1
4	inventory	Inventory	t	{"Super Admin",Admin,"Sales Executive",HR,"Sales Manager"}	2026-04-13 09:53:07.991051+00	1
10	users	Users	t	{"Super Admin",Admin,HR,"Sales Manager"}	2026-04-13 09:53:23.129413+00	1
9	settings	Settings	t	{"Super Admin",Admin,HR,"Sales Manager"}	2026-04-16 07:53:18.501599+00	1
3	purchase	Purchase	f	{"Super Admin",Admin,"Sales Executive",HR}	2026-04-04 06:56:27.537549+00	1
8	communication	Communication	f	{"Super Admin",Admin,"Sales Executive",HR}	2026-04-04 06:56:27.537549+00	1
\.


--
-- Data for Name: notification_push_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification_push_tokens (id, user_id, token, platform, is_active, last_seen_at, created_at, updated_at, tenant_id) FROM stdin;
31	5	cPWHf61yTcGFwvfTPd3JWn:APA91bHC2GY92zSv44X50C4pscFYUHlDB3q3VBtWd9O3O_oPkuucU7vnCr9HTJDdLTWsRJlpkNjEACRwCRGKuvufH_4VtWFfR7wBk6EezsEueLJbRnxzyDw	android	t	2026-04-17 07:54:52.941783	2026-04-17 06:19:37.69215	2026-04-17 07:54:52.941783	1
35	5	fvfGi5rATaGPDKbv62SdWS:APA91bGmBD_Sh9P9Srgx8mNFNioa1kmCJQlw08ai254o9bG4knEHPGI7psnnJDMRIf1UMKgY2n9PhW-uB5YrW4pU_aXh-iq9K3snhmyPD6tQPa6eK-t9Ay0	android	t	2026-04-17 10:17:28.306153	2026-04-17 09:11:53.227356	2026-04-17 10:17:28.306153	1
43	5	c6j42kwWTeqcmjbqIxerca:APA91bEqVIr94t8ttJ77o58QTWIJc-ymfzTSKjmETAhTGmA_wKuQfyA1_E6GgxFGIwvdsOOkGxiDG9-kUUfC3uX1p2YJdAMrEbYAqmZTYBQ6FH8a6dv4968	android	t	2026-04-17 13:46:18.617238	2026-04-17 13:33:30.000298	2026-04-17 13:46:18.617238	1
2	15	e3Uio_WxR7iDMXq_IadQmj:APA91bFqeE_6zyDjp0p3F5HQq9ciDD1OThEr5LtFqMBKogbknahCNMAK7fifVIw16kFW3WHfzTEFGVmv9pH1e4gFAF4hsr0Zyw4PxluCvszoctc7CKMxFrc	android	t	2026-04-17 02:27:45.445367	2026-04-15 17:14:48.787717	2026-04-17 02:27:45.445367	1
48	5	fbsMjIIVRQebt7XeoGzc4p:APA91bGcj9f7mEox8b4v4WWkM_FJ0rsC3Q-IqcwPSijG8B3TTvbmKbCjHYz3bktJEYfnJRSSS2k1VGj55nwr9OnZlFyxvdOOpmMGSLptc8h3e6m7c376i44	android	t	2026-04-19 02:30:02.165982	2026-04-18 02:21:26.758541	2026-04-19 02:30:02.165982	1
28	15	e3Uio_WxR7iDMXq_IadQmj:APA91bEQ5GKR1HBQ6Upwr-dOa1kCpUTvu4MoRag8tDLXLs0B6BwxlHkcfk3fM_1r9JuDpu4axgTEVtzh0MTdOZJ7sNy-eeNIkN5r62AOZ50i4UVRnX4D7v8	android	t	2026-04-26 12:34:06.789863	2026-04-17 02:29:31.396628	2026-04-26 12:34:06.789863	1
1	15	eq6x1kijRGCtduOFpq6tMB:APA91bHMbh0GOofz_LsC7SYhfqJpG0683mvEsZg5LUJzn-az1u9juWsNKP5yeUWZEL59BIGs2ITmQfJn50tzuE5TIIDgFNex4pGSxThfMGivOOXt8FOJVt4	android	t	2026-05-10 12:39:02.680878	2026-04-15 17:14:28.674509	2026-05-10 12:39:02.680878	1
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, title, body, type, module, link, is_read, created_at, tenant_id) FROM stdin;
57	15	New lead	Karthik was added.	info	crm	/crm?lead=355	f	2026-04-16 15:40:14.332498+00	\N
58	15	New lead	Thava Selvan was added.	info	crm	/crm?lead=356	f	2026-04-16 16:00:18.222831+00	\N
53	15	New lead	Foster Energy Pvt Ltd, was added.	info	crm	/crm?lead=354	t	2026-04-16 04:56:41.896065+00	1
59	15	New lead	Seena Vas was added.	info	crm	/crm?lead=357	f	2026-04-17 06:10:14.438952+00	\N
61	15	New lead	svs manian was added.	info	crm	/crm?lead=359	f	2026-04-17 07:00:15.375352+00	\N
62	15	New lead	svs manian was added.	info	crm	/crm?lead=360	f	2026-04-17 07:00:22.036773+00	\N
63	15	New lead	Test Lead 1 was added.	info	crm	/crm?lead=361	f	2026-04-17 07:10:00.644762+00	\N
65	15	New lead	Anwar Basha was added.	info	crm	/crm?lead=362	f	2026-04-17 07:30:15.883552+00	\N
66	15	New lead	Anwar Basha was added.	info	crm	/crm?lead=363	f	2026-04-17 07:30:20.814154+00	\N
69	15	New lead	Karthik was added.	info	crm	/crm?lead=366	f	2026-04-17 08:04:49.116089+00	\N
70	15	New lead	Thava Selvan was added.	info	crm	/crm?lead=367	f	2026-04-17 08:04:50.258803+00	\N
71	15	New lead	Seena Vas was added.	info	crm	/crm?lead=368	f	2026-04-17 08:04:51.399088+00	\N
72	15	New lead	svs manian was added.	info	crm	/crm?lead=370	f	2026-04-17 08:04:52.540208+00	\N
73	15	New lead	test leads 3 was added.	info	crm	/crm?lead=369	f	2026-04-17 08:04:52.850444+00	\N
74	15	New lead	Anwar Basha was added.	info	crm	/crm?lead=371	f	2026-04-17 08:04:53.751611+00	\N
75	15	New lead	test leads was added.	info	crm	/crm?lead=372	f	2026-04-17 09:56:40.735876+00	\N
76	15	New lead	Mr.Gopalakrishnan, was added.	info	crm	/crm?lead=373	f	2026-04-17 13:37:45.917633+00	\N
77	15	New lead	THOUSEEF was added.	info	crm	/crm?lead=374	f	2026-04-17 15:20:30.479466+00	\N
78	15	New lead	Suresh Rajendran was added.	info	crm	/crm?lead=375	f	2026-04-17 15:40:29.408387+00	\N
79	16	Lead assigned to you: svs manian	Open to view details	info	crm	/crm?lead=360	f	2026-04-18 05:22:37.09556+00	\N
80	15	New lead	Shri Suresh Timbers & Tiles was added.	info	crm	/crm?lead=376	f	2026-04-18 06:13:49.081598+00	\N
81	15	New lead assigned: Shri Suresh Timbers & Tiles	Open to view details	info	crm	/crm?lead=376	f	2026-04-18 06:13:49.563905+00	\N
82	15	New lead	Vinoth Devendra was added.	info	crm	/crm?lead=377	f	2026-04-18 08:20:26.659332+00	\N
83	15	New lead	Vinoth Devendra was added.	info	crm	/crm?lead=378	f	2026-04-18 08:20:26.671864+00	\N
84	15	New lead	ANVI GROUPS, was added.	info	crm	/crm?lead=379	f	2026-04-18 10:21:00.104951+00	\N
85	15	New lead	Asian Building Material Pvt Ltd, was added.	info	crm	/crm?lead=380	f	2026-04-18 10:45:37.37146+00	\N
86	15	New lead	vinoth Devendra was added.	info	crm	/crm?lead=381	f	2026-04-18 12:07:51.95062+00	\N
87	16	New lead assigned: vinoth Devendra	Open to view details	info	crm	/crm?lead=381	f	2026-04-18 12:07:52.437082+00	\N
88	15	Lead assigned to you: ANVI GROUPS,	Open to view details	info	crm	/crm?lead=379	f	2026-04-19 02:30:53.247628+00	\N
89	5	Lead assigned to you: Asian Building Material Pvt Ltd,	Open to view details	info	crm	/crm?lead=380	f	2026-04-19 02:31:29.635486+00	\N
90	15	Lead assigned to you: Mr.Gopalakrishnan,	Open to view details	info	crm	/crm?lead=373	f	2026-04-19 02:39:22.357476+00	\N
91	15	Lead assigned to you: SRI KARTHIK ENTERPRISES	Open to view details	info	crm	/crm?lead=364	f	2026-04-19 02:39:42.523565+00	\N
94	15	New lead	Rajakumar Ramaiah was added.	info	crm	/crm?lead=382	f	2026-04-19 06:50:27.794714+00	\N
95	15	New lead	Rajakumar Ramaiah was added.	info	crm	/crm?lead=383	f	2026-04-19 06:50:29.594092+00	\N
96	15	New lead	Anbarasan was added.	info	crm	/crm?lead=384	f	2026-04-19 14:00:29.857453+00	\N
97	15	New lead	Anbarasan was added.	info	crm	/crm?lead=385	f	2026-04-19 14:00:31.028589+00	\N
56	15	Test push notification	FCM test sent at 2026-04-16T04:58:39.679Z	info	notifications	\N	t	2026-04-16 04:58:41.130746+00	1
55	15	Test push notification	FCM test sent at 2026-04-16T04:57:59.227Z	info	notifications	\N	t	2026-04-16 04:58:00.661436+00	1
54	15	Test push notification	FCM test sent at 2026-04-16T04:57:03.989Z	info	notifications	\N	t	2026-04-16 04:57:05.435728+00	1
52	15	Test push notification	FCM test sent at 2026-04-16T04:51:33.557Z	info	notifications	\N	t	2026-04-16 04:51:33.681225+00	1
51	15	Test push notification	FCM test sent at 2026-04-16T04:37:27.934Z	info	notifications	\N	t	2026-04-16 04:37:29.482728+00	1
50	15	Test push notification	FCM test sent at 2026-04-16T04:36:38.025Z	info	notifications	\N	t	2026-04-16 04:36:39.572802+00	1
49	15	Test push notification	FCM test sent at 2026-04-16T04:36:01.155Z	info	notifications	\N	t	2026-04-16 04:36:02.712111+00	1
39	15	Follow-up scheduled	contacted	info	crm	/crm?lead=332	t	2026-04-13 11:10:16.43931+00	1
40	16	Lead reassigned to you: Yuvaraj Rubini	Open to view details	info	crm	/crm?lead=342	t	2026-04-14 08:47:24.314423+00	1
46	16	Lead reassigned to you: Dharmaraj Raja	Open to view details	info	crm	/crm?lead=348	t	2026-04-15 05:56:20.543745+00	1
38	16	Follow-up scheduled	meeting	info	crm	/crm?lead=333	t	2026-04-13 11:10:04.500286+00	1
37	16	Lead reassigned to you: Iyya Ppan	Open to view details	info	crm	/crm?lead=333	t	2026-04-13 11:08:33.250474+00	1
41	16	Lead reassigned to you: Mani Barathi	Open to view details	info	crm	/crm?lead=343	t	2026-04-14 08:47:56.662528+00	1
42	16	Follow-up scheduled	Open to view details	info	crm	/crm?lead=343	t	2026-04-14 10:18:13.88175+00	1
43	16	Lead reassigned to you: Arun Kumar	Open to view details	info	crm	/crm?lead=347	t	2026-04-15 05:12:45.103534+00	1
44	16	Lead reassigned to you: SANKAR.D	Open to view details	info	crm	/crm?lead=346	t	2026-04-15 05:13:16.836516+00	1
45	16	Lead reassigned to you: Suresh Raj	Open to view details	info	crm	/crm?lead=344	t	2026-04-15 05:13:37.477308+00	1
48	5	Test push notification	FCM test sent at 2026-04-16T04:33:37.385Z	info	notifications	\N	f	2026-04-16 04:33:38.952452+00	1
47	5	Test push notification	FCM test sent at 2026-04-16T04:26:56.634Z	info	notifications	\N	f	2026-04-16 04:26:58.160712+00	1
36	8	Lead reassigned to you: praveen	Open to view details	info	crm	/crm?lead=332	f	2026-04-13 11:06:03.355126+00	1
35	8	Lead reassigned to you: Iyya Ppan	Open to view details	info	crm	/crm?lead=333	f	2026-04-13 11:05:16.539073+00	1
34	8	Lead reassigned to you: Chandru Marappan	Open to view details	info	crm	/crm?lead=334	f	2026-04-13 11:04:49.598846+00	1
33	8	Lead reassigned to you: Sundarrajan A	Open to view details	info	crm	/crm?lead=335	f	2026-04-13 11:04:21.859839+00	1
32	8	Lead reassigned to you: praveen	Open to view details	info	crm	/crm?lead=332	f	2026-04-13 10:59:29.704828+00	1
31	8	Lead reassigned to you: Iyya Ppan	Open to view details	info	crm	/crm?lead=333	f	2026-04-13 10:58:39.201684+00	1
30	8	Lead reassigned to you: Chandru Marappan	Open to view details	info	crm	/crm?lead=334	f	2026-04-13 10:58:24.526583+00	1
29	8	Lead reassigned to you: Sundarrajan A	Open to view details	info	crm	/crm?lead=335	f	2026-04-13 10:58:03.429239+00	1
28	8	Lead reassigned to you: Iyya Ppan	Open to view details	info	crm	/crm?lead=333	f	2026-04-13 10:16:01.117234+00	1
27	8	Lead reassigned to you: Chandru Marappan	Open to view details	info	crm	/crm?lead=334	f	2026-04-13 10:15:41.110872+00	1
26	8	Lead reassigned to you: Sundarrajan A	Open to view details	info	crm	/crm?lead=335	f	2026-04-13 10:14:36.86145+00	1
25	8	Lead reassigned to you: praveen	Open to view details	info	crm	/crm?lead=332	f	2026-04-13 10:10:37.291399+00	1
24	8	Lead reassigned to you: Iyya Ppan	Open to view details	info	crm	/crm?lead=333	f	2026-04-13 10:10:21.021324+00	1
23	8	Lead reassigned to you: Chandru Marappan	Open to view details	info	crm	/crm?lead=334	f	2026-04-13 10:10:01.44258+00	1
22	8	Lead reassigned to you: Sundarrajan A	Open to view details	info	crm	/crm?lead=335	f	2026-04-13 10:09:38.037176+00	1
21	8	Lead reassigned to you: praveen	Open to view details	info	crm	/crm?lead=332	f	2026-04-13 09:57:02.989256+00	1
20	8	Lead reassigned to you: Sundarrajan A	Open to view details	info	crm	/crm?lead=335	f	2026-04-13 09:56:30.118949+00	1
19	8	Lead reassigned to you: Iyya Ppan	Open to view details	info	crm	/crm?lead=333	f	2026-04-13 09:45:39.505998+00	1
18	8	Lead reassigned to you: Chandru Marappan	Open to view details	info	crm	/crm?lead=334	f	2026-04-13 09:45:22.628813+00	1
17	8	Lead reassigned to you: Sundarrajan A	Open to view details	info	crm	/crm?lead=335	f	2026-04-13 09:44:03.009356+00	1
60	15	New lead	Seena Vas was added.	info	crm	/crm?lead=358	f	2026-04-17 06:10:29.974573+00	\N
64	16	Lead assigned to you: Sakunthala Srinivasan	Open to view details	info	crm	/crm?lead=353	f	2026-04-17 07:15:58.250766+00	\N
67	15	New lead	SRI KARTHIK ENTERPRISES was added.	info	crm	/crm?lead=364	f	2026-04-17 07:46:59.733229+00	\N
68	15	New lead	test leads 1 was added.	info	crm	/crm?lead=365	f	2026-04-17 08:04:05.428471+00	\N
92	15	Lead assigned to you: Foster Energy Pvt Ltd,	Open to view details	info	crm	/crm?lead=354	f	2026-04-19 02:41:12.386806+00	\N
93	5	Lead assigned to you: M. S .CONSTRUCTION,	Open to view details	info	crm	/crm?lead=352	f	2026-04-19 02:42:01.712218+00	\N
98	15	New lead	Manikandan Cl was added.	info	crm	/crm?lead=386	f	2026-04-20 11:20:02.53308+00	\N
99	15	New lead	Ramesh Babu was added.	info	crm	/crm?lead=387	f	2026-04-20 12:30:02.880981+00	\N
100	15	New lead	S Vijayakumar was added.	info	crm	/crm?lead=388	f	2026-04-20 12:50:05.416217+00	\N
101	15	New lead	Sri Jayram Agencies was added.	info	crm	/crm?lead=389	f	2026-04-21 04:28:47.656976+00	\N
102	15	New lead assigned: Sri Jayram Agencies	Open to view details	info	crm	/crm?lead=389	f	2026-04-21 04:28:47.671131+00	\N
103	15	New lead	Mr. Gangatharan was added.	info	crm	/crm?lead=390	f	2026-04-21 06:07:42.81068+00	\N
104	16	Lead stage updated	Shankar R moved "svs manian" from New to Contacted.	info	crm	/crm?lead=360	f	2026-04-21 06:13:17.633372+00	\N
105	16	Lead stage updated	Shankar R moved "Sakunthala Srinivasan" from New to RNR.	info	crm	/crm?lead=353	f	2026-04-21 06:14:28.162178+00	\N
106	15	New lead	paramasivan Ramaiah was added.	info	crm	/crm?lead=391	f	2026-04-21 13:40:03.971339+00	\N
107	15	New lead	Natarajan Subramani was added.	info	crm	/crm?lead=392	f	2026-04-22 07:20:04.396387+00	\N
108	15	New lead	Santhi Kiruba was added.	info	crm	/crm?lead=393	f	2026-04-22 15:10:04.751739+00	\N
109	15	New lead	Sridhar P K was added.	info	crm	/crm?lead=394	f	2026-04-23 06:30:03.611834+00	\N
110	15	New lead	Syed Anszary was added.	info	crm	/crm?lead=395	f	2026-04-23 15:10:04.775589+00	\N
111	15	New lead	Deenadayalan Kuppa Naidu Gunapushnam was added.	info	crm	/crm?lead=396	f	2026-04-24 12:40:04.162695+00	\N
112	15	Lead stage updated	Shankar R moved "ANVI GROUPS," from Quotation Sent to Proposal Sent.	info	crm	/crm?lead=379	f	2026-04-25 13:13:26.957172+00	\N
113	15	Lead stage updated	Shankar R moved "ANVI GROUPS," from Proposal Sent to Quotation Sent.	info	crm	/crm?lead=379	f	2026-04-25 13:13:33.009067+00	\N
114	15	New lead	Jawahar G was added.	info	crm	/crm?lead=397	f	2026-04-26 14:30:04.217305+00	\N
115	15	New lead	SREE LORD VENKATACHALAPATHI EDUCATIONAL TRUST, was added.	info	crm	/crm?lead=398	f	2026-05-02 07:51:40.957536+00	\N
116	15	New lead	Sridhar Janarthanam was added.	info	crm	/crm?lead=399	f	2026-05-02 13:10:04.804056+00	\N
117	15	New lead	Sushil jain was added.	info	crm	/crm?lead=400	f	2026-05-02 13:30:03.737627+00	\N
118	15	New lead	Venkadesh Palanisamy was added.	info	crm	/crm?lead=401	f	2026-05-02 13:40:05.509872+00	\N
119	15	New lead	GOWTHAMAN was added.	info	crm	/crm?lead=402	f	2026-05-03 05:40:05.237363+00	\N
120	15	New lead	K M G Surendran was added.	info	crm	/crm?lead=403	f	2026-05-03 07:00:04.391771+00	\N
121	15	New lead	Mohideen Khaja was added.	info	crm	/crm?lead=404	f	2026-05-03 08:40:04.929344+00	\N
122	15	New lead	wilson was added.	info	crm	/crm?lead=405	f	2026-05-04 12:10:04.544638+00	\N
123	15	New lead	Khan Amjath was added.	info	crm	/crm?lead=406	f	2026-05-04 12:10:04.631561+00	\N
124	15	New lead	Sri was added.	info	crm	/crm?lead=407	f	2026-05-04 12:10:04.680432+00	\N
125	15	New lead	Dhanasekar K was added.	info	crm	/crm?lead=408	f	2026-05-04 12:10:04.870233+00	\N
126	15	New lead	Uday Kumar was added.	info	crm	/crm?lead=409	f	2026-05-04 16:50:06.425534+00	\N
127	15	New lead	Upendra Traders was added.	info	crm	/crm?lead=410	f	2026-05-05 05:15:44.201361+00	\N
128	15	New lead assigned: Upendra Traders	Open to view details	info	crm	/crm?lead=410	f	2026-05-05 05:15:44.210905+00	\N
129	15	New lead	M/s Kuviyam Infra Developers Pvt Ltd was added.	info	crm	/crm?lead=411	f	2026-05-05 07:33:23.541093+00	\N
130	15	New lead assigned: M/s Kuviyam Infra Developers Pvt Ltd	M/s Kuviyam Infra Developers Pvt Ltd	info	crm	/crm?lead=411	f	2026-05-05 07:33:23.553837+00	\N
131	15	New lead	Dhamodharan p was added.	info	crm	/crm?lead=412	f	2026-05-05 12:20:05.72777+00	\N
132	15	New lead	sivasankaran was added.	info	crm	/crm?lead=413	f	2026-05-05 13:00:04.765883+00	\N
133	15	New lead	Mani Gramani was added.	info	crm	/crm?lead=414	f	2026-05-05 14:00:03.885845+00	\N
134	15	New lead	Suriya Prakash was added.	info	crm	/crm?lead=415	f	2026-05-06 13:40:04.131841+00	\N
135	15	New lead	Akbar Chezhian was added.	info	crm	/crm?lead=416	f	2026-05-06 13:40:04.15297+00	\N
136	15	New lead	Baskar Palanivel was added.	info	crm	/crm?lead=417	f	2026-05-06 14:10:03.96986+00	\N
137	15	New lead	O.N.பாஸ் was added.	info	crm	/crm?lead=418	f	2026-05-06 16:10:03.839621+00	\N
138	15	New lead	O.N.Boss was added.	info	crm	/crm?lead=419	f	2026-05-07 04:15:33.257622+00	\N
139	16	New lead assigned: O.N.Boss	Open to view details	info	crm	/crm?lead=419	f	2026-05-07 04:15:33.264993+00	\N
140	15	New lead	p c Muralee was added.	info	crm	/crm?lead=420	f	2026-05-07 13:10:03.265059+00	\N
141	15	New lead	Salai Kuberan was added.	info	crm	/crm?lead=421	f	2026-05-07 13:30:01.305971+00	\N
142	15	New lead	M Muthusamy was added.	info	crm	/crm?lead=422	f	2026-05-07 13:50:01.126498+00	\N
143	15	New lead	Felix Lins was added.	info	crm	/crm?lead=423	f	2026-05-08 04:50:04.685843+00	\N
144	15	New lead	Jegatheesan ple send pr list catlJega was added.	info	crm	/crm?lead=424	f	2026-05-08 10:10:04.264617+00	\N
145	15	New lead	Muralidharan V K was added.	info	crm	/crm?lead=425	f	2026-05-08 12:50:01.110525+00	\N
146	15	New lead	Baskar Narayanan was added.	info	crm	/crm?lead=426	f	2026-05-08 13:20:01.083251+00	\N
147	15	New lead	Paramesh Kumar was added.	info	crm	/crm?lead=427	f	2026-05-08 13:20:02.146037+00	\N
148	15	New lead	Suresh Natraj Suresh was added.	info	crm	/crm?lead=428	f	2026-05-08 13:20:03.45496+00	\N
149	15	New lead	Aroon was added.	info	crm	/crm?lead=429	f	2026-05-08 13:30:05.128678+00	\N
150	15	New lead	Navas Navas was added.	info	crm	/crm?lead=430	f	2026-05-09 07:40:01.272878+00	\N
151	15	New lead	gangadharan.k was added.	info	crm	/crm?lead=431	f	2026-05-09 07:40:01.298365+00	\N
152	15	New lead	Ahamed Mohamed Ali was added.	info	crm	/crm?lead=432	f	2026-05-09 08:00:01.430473+00	\N
153	15	New lead	Sri Ramachandra Traders was added.	info	crm	/crm?lead=433	f	2026-05-09 09:27:44.797512+00	\N
154	15	New lead assigned: Sri Ramachandra Traders	Open to view details	info	crm	/crm?lead=433	f	2026-05-09 09:27:44.805773+00	\N
155	15	New lead	Muralikrishna was added.	info	crm	/crm?lead=434	f	2026-05-09 12:40:01.45415+00	\N
156	15	New lead	Mohanarangam.E was added.	info	crm	/crm?lead=435	f	2026-05-09 14:20:04.398736+00	\N
157	15	New lead	senthilkumar was added.	info	crm	/crm?lead=436	f	2026-05-09 14:40:03.856378+00	\N
158	15	New lead	Zakir hussain  b was added.	info	crm	/crm?lead=437	f	2026-05-10 06:10:02.986192+00	\N
159	15	New lead	Vengatesh N was added.	info	crm	/crm?lead=438	f	2026-05-10 14:40:03.971464+00	\N
160	15	New lead	Mohammed Farooq was added.	info	crm	/crm?lead=439	f	2026-05-10 15:00:04.158599+00	\N
161	15	New lead	ஏ.பி ராஜா was added.	info	crm	/crm?lead=440	f	2026-05-11 12:00:06.240302+00	\N
162	15	New lead	Annamalai Kumaravel was added.	info	crm	/crm?lead=441	f	2026-05-11 12:00:06.310117+00	\N
163	15	New lead	Balakrishnamurthy Murthy was added.	info	crm	/crm?lead=442	f	2026-05-11 12:10:04.443315+00	\N
164	15	New lead	Cbabu Babu was added.	info	crm	/crm?lead=443	f	2026-05-11 12:20:06.623768+00	\N
165	15	New lead	Jayauday ragav was added.	info	crm	/crm?lead=444	f	2026-05-12 11:00:04.005637+00	\N
166	15	New lead	Rama Krishnan was added.	info	crm	/crm?lead=445	f	2026-05-12 11:20:01.101399+00	\N
167	15	New lead	Prasath Siva was added.	info	crm	/crm?lead=446	f	2026-05-12 14:20:03.487276+00	\N
168	15	New lead	Thangavel N was added.	info	crm	/crm?lead=447	f	2026-05-13 08:10:02.027611+00	\N
169	15	New lead	KL Shanmugam was added.	info	crm	/crm?lead=448	f	2026-05-13 13:30:04.235338+00	\N
170	15	New lead	Meenakshi subramanian s.j was added.	info	crm	/crm?lead=449	f	2026-05-13 13:40:03.29757+00	\N
171	15	New lead	Mr. Jayaraj .s was added.	info	crm	/crm?lead=450	f	2026-05-14 06:15:03.590089+00	\N
172	15	New lead assigned: Mr. Jayaraj .s	Open to view details	info	crm	/crm?lead=450	f	2026-05-14 06:15:03.600882+00	\N
173	15	New lead	ஆறு. மகேந்திரன் was added.	info	crm	/crm?lead=451	f	2026-05-14 12:10:03.725007+00	\N
174	15	New lead	Nagarajan Shanmugam was added.	info	crm	/crm?lead=452	f	2026-05-14 12:20:03.271163+00	\N
175	15	New lead	Martin Bala was added.	info	crm	/crm?lead=453	f	2026-05-14 12:40:02.66226+00	\N
176	15	New lead	john was added.	info	crm	/crm?lead=454	f	2026-05-14 15:30:12.768538+00	\N
177	15	New lead	Guna Vel was added.	info	crm	/crm?lead=455	f	2026-05-15 08:10:04.273092+00	\N
178	15	New lead	PSN Construction was added.	info	crm	/crm?lead=456	f	2026-05-15 11:50:17.481543+00	\N
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, invoice_id, amount, payment_date, method, reference, notes, created_by, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: payroll; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payroll (id, employee_id, month, year, basic, hra, allowances, deductions, pf, gross, net, status, paid_on, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permissions (id, module, action, label) FROM stdin;
1	crm	view	CRM ??? View own leads
2	crm	view_all	CRM ??? View all leads
3	crm	create	CRM ??? Create leads
4	crm	create_all	CRM ??? Create leads for others
5	crm	edit	CRM ??? Edit own leads
6	crm	edit_all	CRM ??? Edit all leads
7	crm	delete	CRM ??? Delete own leads
8	crm	delete_all	CRM ??? Delete any lead
9	sales	view	Sales ??? View own records
10	sales	view_all	Sales ??? View all records
11	sales	create	Sales ??? Create records
12	sales	create_all	Sales ??? Create on behalf of others
13	sales	edit	Sales ??? Edit own records
14	sales	edit_all	Sales ??? Edit all records
15	sales	delete	Sales ??? Delete own records
16	sales	delete_all	Sales ??? Delete any record
17	purchase	view	Purchase ??? View own records
18	purchase	view_all	Purchase ??? View all records
19	purchase	create	Purchase ??? Create records
20	purchase	create_all	Purchase ??? Create on behalf of others
21	purchase	edit	Purchase ??? Edit own records
22	purchase	edit_all	Purchase ??? Edit all records
23	purchase	delete	Purchase ??? Delete own records
24	purchase	delete_all	Purchase ??? Delete any record
25	inventory	view	Inventory ??? View own records
26	inventory	view_all	Inventory ??? View all records
27	inventory	create	Inventory ??? Create records
28	inventory	create_all	Inventory ??? Create on behalf of others
29	inventory	edit	Inventory ??? Edit own records
30	inventory	edit_all	Inventory ??? Edit all records
31	inventory	delete	Inventory ??? Delete own records
32	inventory	delete_all	Inventory ??? Delete any record
33	production	view	Production ??? View own records
34	production	view_all	Production ??? View all records
35	production	create	Production ??? Create records
36	production	create_all	Production ??? Create on behalf of others
37	production	edit	Production ??? Edit own records
38	production	edit_all	Production ??? Edit all records
39	production	delete	Production ??? Delete own records
40	production	delete_all	Production ??? Delete any record
41	finance	view	Finance ??? View own records
42	finance	view_all	Finance ??? View all records
43	finance	create	Finance ??? Create records
44	finance	create_all	Finance ??? Create on behalf of others
45	finance	edit	Finance ??? Edit own records
46	finance	edit_all	Finance ??? Edit all records
47	finance	delete	Finance ??? Delete own records
48	finance	delete_all	Finance ??? Delete any record
49	hr	view	HR ??? View own records
50	hr	view_all	HR ??? View all records
51	hr	create	HR ??? Create records
52	hr	create_all	HR ??? Create on behalf of others
53	hr	edit	HR ??? Edit own records
54	hr	edit_all	HR ??? Edit all records
55	hr	delete	HR ??? Delete own records
56	hr	delete_all	HR ??? Delete any record
57	communication	view	Communication ??? View own records
58	communication	view_all	Communication ??? View all records
59	communication	create	Communication ??? Create records
60	communication	create_all	Communication ??? Create on behalf of others
61	communication	edit	Communication ??? Edit own records
62	communication	edit_all	Communication ??? Edit all records
63	communication	delete	Communication ??? Delete own records
64	communication	delete_all	Communication ??? Delete any record
65	settings	view	Settings ??? View settings
66	settings	view_all	Settings ??? View all settings & audit logs
67	settings	create	Settings ??? Create entries
68	settings	create_all	Settings ??? Create system-wide entries
69	settings	edit	Settings ??? Edit own settings
70	settings	edit_all	Settings ??? Edit all settings
71	settings	delete	Settings ??? Delete own entries
72	settings	delete_all	Settings ??? Delete any entry
73	users	view	Users ??? View own profile
74	users	view_all	Users ??? View all users
75	users	create	Users ??? Create users
76	users	create_all	Users ??? Create users with any role
77	users	edit	Users ??? Edit own profile
78	users	edit_all	Users ??? Edit any user
79	users	delete	Users ??? Deactivate own account
80	users	delete_all	Users ??? Delete any user
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, name, sku, hsn_code, description, unit, purchase_price, sale_price, gst_rate, low_stock_alert, is_active, created_at, code, category, brand_id, image_url, tenant_id) FROM stdin;
44	SFRC Concrete Manhole Cover 12" X 12" ,MD-10 kg.	MD	6810	\N	pcs	0.00	450.00	0.00	0	t	2026-04-14 11:42:05.703423+00	11	Manhole	1	\N	1
56	Igloo Tiles 12"x12"x15mm thickness,3.2kg/No.	Roof Tiles	6810	\N	pcs	0.00	48.00	0.00	0	t	2026-04-15 10:20:15.813057+00	01	Roof Tiles	1	\N	1
58	Igloo Tiles 12"x12"x20 mm thickness.	Roof Tile	6810	\N	pcs	0.00	55.00	0.00	0	t	2026-04-15 10:54:46.259315+00	002	Roof Tiles	1	\N	1
52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	kerb	6810	\N	pcs	0.00	260.00	0.00	0	t	2026-04-15 06:29:44.519682+00	001	Kerbstone	1	\N	1
59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	SFRC	6810	\N	pcs	0.00	1500.00	18.01	0	t	2026-04-17 07:51:29.130885+00	005	Manhole	1	\N	1
61	SFRC Concrete Manhole Cover 32" X 32" ,MD-116 Kg	SFRC 1	6810	\N	pcs	0.00	1600.00	0.00	0	t	2026-04-18 06:25:48.695223+00	004	Manhole	1	\N	1
62	SFRC Concrete Manhole Cover 18" X 18" ,MD- 29 kG	SFRC 2	6810	\N	pcs	0.00	650.00	0.00	0	t	2026-04-18 06:27:23.346127+00	009	Manhole	1	\N	1
65	SFRC Concrete Manhole Cover 15" X 15" ,MD-18 kg.	SFRC6	6810	\N	pcs	0.00	0.00	0.00	0	t	2026-04-18 09:31:02.365703+00	015	Manhole	1	\N	1
66	SFRC Concrete Manhole Cover 21" X 21" ,MD-32 kg.	SFRC7	6810	\N	pcs	0.00	0.00	0.00	0	t	2026-04-18 09:34:14.797598+00	014	Manhole	1	\N	1
68	SFRC Concrete Manhole Cover 24" X 24" ,LD -41 Kg.	SFRC 10	6810	\N	pcs	0.00	0.00	0.00	0	t	2026-04-18 09:36:40.63052+00	016	Manhole	1	\N	1
70	Igloo Tiles 12"x12"x15mm thickness,3.2kg/No.	ROOF TILE	6810	\N	Box	0.00	225.00	0.00	0	t	2026-04-18 10:47:22.026138+00	003	Roof Tiles	1	\N	1
71	SFRC Concrete Manhole Cover 36" x 36" , HD - 250 Kg	SFRC11	6810	\N	pcs	3000.00	0.00	18.00	0	t	2026-04-21 06:10:09.634413+00	020	Manhole	1	\N	1
72	SFRC Concrete Manhole Cover 32" x 32" , HD-170 Kg	SFRC10	6810	\N	pcs	0.00	0.00	18.00	0	t	2026-04-21 06:12:51.058454+00	021	Manhole	1	\N	1
\.


--
-- Data for Name: proposal_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proposal_items (id, proposal_id, product_id, description, quantity, unit_price, gst_rate, total) FROM stdin;
\.


--
-- Data for Name: proposals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proposals (id, proposal_number, customer_id, lead_id, status, valid_until, notes, total_amount, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: purchase_invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_invoices (id, invoice_number, vendor_id, po_id, invoice_date, due_date, amount, gst_amount, total_amount, status, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: purchase_order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_order_items (id, po_id, product_id, quantity, unit_price, gst_rate, total, tenant_id) FROM stdin;
\.


--
-- Data for Name: purchase_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.purchase_orders (id, po_number, vendor_id, status, order_date, expected_date, notes, total_amount, created_by, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: quotation_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quotation_items (id, quotation_id, product_id, description, quantity, unit_price, gst_rate, total, discount, cgst, sgst, igst) FROM stdin;
55	33	52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	670.000	240.00	18.00	160800.00	0.00	12264.41	12264.41	0.00
60	27	58	Igloo Tiles 12"x12"x20 mm thickness.	15000.000	53.00	18.00	795000.00	0.00	0.00	0.00	0.00
69	44	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	2.000	1500.00	18.00	3540.00	0.00	270.00	270.00	0.00
72	45	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	7.000	1500.00	18.00	10500.00	0.00	800.85	800.85	0.00
78	47	56	Igloo Tiles 12"x12"x15mm thickness,3.2kg/No.	5000.000	43.00	18.00	215000.00	0.00	16398.31	16398.31	0.00
79	47	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	20.000	1100.00	18.00	22000.00	0.00	1677.97	1677.97	0.00
81	47	44	SFRC Concrete Manhole Cover 12" X 12" ,MD-10 kg.	15.000	280.00	18.00	4200.00	0.00	320.34	320.34	0.00
82	47	\N		1.000	0.00	0.00	0.00	0.00	0.00	0.00	0.00
83	47	62	SFRC Concrete Manhole Cover 18" X 18" ,MD- 29 kG	10.000	650.00	18.00	6500.00	0.00	495.76	495.76	0.00
84	47	61	SFRC Concrete Manhole Cover 32" X 32" ,MD-116 Kg	1.000	1600.00	16.00	1600.00	0.00	110.34	110.34	0.00
36	21	44	SFRC Concrete Manhole Cover 12" X 12" ,MD-10 kg.	50.000	450.00	0.00	22500.00	0.00	0.00	0.00	0.00
39	24	52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	50.000	260.00	0.00	13000.00	0.00	0.00	0.00	0.00
42	25	56	Igloo Tiles 12"x12"x15mm thickness,3.2kg/No.	2500.000	48.00	0.00	120000.00	0.00	0.00	0.00	0.00
80	47	\N	SFRC Concrete Manhole Cover 15" X 15" ,MD-21 kg.	10.000	450.00	18.00	4500.00	0.00	343.22	343.22	0.00
38	23	\N	SFRC Concrete Manhole Cover 15" X 15" ,MD-21 kg.	50.000	700.00	0.00	35000.00	0.00	0.00	0.00	0.00
50	28	\N	iglootiles	1000.000	45.00	18.00	45000.00	0.00	3432.21	3432.21	0.00
99	48	56	Igloo Tiles 12"x12"x15mm thickness,3.2kg/No.	5000.000	43.00	18.00	215000.00	0.00	16398.31	16398.31	0.00
100	48	61	SFRC Concrete Manhole Cover 32" X 32" ,MD-116 Kg	10.000	1600.00	18.00	16000.00	0.00	1220.34	1220.34	0.00
101	48	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	20.000	1100.00	18.00	22000.00	0.00	1677.97	1677.97	0.00
102	48	62	SFRC Concrete Manhole Cover 18" X 18" ,MD- 29 kG	10.000	650.00	18.00	6500.00	0.00	495.76	495.76	0.00
103	48	44	SFRC Concrete Manhole Cover 12" X 12" ,MD-10 kg.	15.000	280.00	18.00	4200.00	0.00	320.34	320.34	0.00
104	48	65	SFRC Concrete Manhole Cover 15" X 15" ,MD-18 kg.	10.000	450.00	18.00	4500.00	0.00	343.22	343.22	0.00
110	50	61	SFRC Concrete Manhole Cover 32" X 32" ,MD-116 Kg	20.000	1800.00	18.00	36000.00	0.00	2745.76	2745.76	0.00
111	50	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	60.000	1100.00	18.00	66000.00	0.00	5033.90	5033.90	0.00
112	50	62	SFRC Concrete Manhole Cover 18" X 18" ,MD- 29 kG	20.000	650.00	18.00	13000.00	0.00	991.53	991.53	0.00
113	50	65	SFRC Concrete Manhole Cover 15" X 15" ,MD-18 kg.	20.000	450.00	18.00	9000.00	0.00	686.44	686.44	0.00
114	50	44	SFRC Concrete Manhole Cover 12" X 12" ,MD-10 kg.	20.000	280.00	18.00	5600.00	0.00	427.12	427.12	0.00
117	51	70	Igloo Tiles 12"x12"x15mm thickness,3.2kg/No.	1000.000	225.00	18.00	225000.00	0.00	17161.02	17161.02	0.00
119	53	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	1.000	1100.00	18.00	1100.00	0.00	83.90	83.90	0.00
126	54	71	SFRC Concrete Manhole Cover 36" x 36" , HD - 250 Kg	1.000	3000.00	18.00	3000.00	0.00	228.81	228.81	0.00
127	54	72	SFRC Concrete Manhole Cover 32" x 32" , HD-170 Kg	1.000	2400.00	18.00	2400.00	0.00	183.05	183.05	0.00
128	54	61	SFRC Concrete Manhole Cover 32" X 32" ,MD-116 Kg	1.000	1600.00	18.00	1600.00	0.00	122.03	122.03	0.00
132	55	71	SFRC Concrete Manhole Cover 36" x 36" , HD - 250 Kg	1.000	3000.00	18.00	3000.00	0.00	228.81	228.81	0.00
133	55	72	SFRC Concrete Manhole Cover 32" x 32" , HD-170 Kg	1.000	2400.00	18.00	2400.00	0.00	183.05	183.05	0.00
134	55	61	SFRC Concrete Manhole Cover 32" X 32" ,MD-116 Kg	1.000	1600.00	27.00	1600.00	0.00	170.08	170.08	0.00
135	56	52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	400.000	205.00	18.00	96760.00	0.00	7380.00	7380.00	0.00
158	57	44	SFRC Concrete Manhole Cover 12" X 12" ,MD-10 kg.	50.000	280.00	18.00	14000.00	0.00	1067.80	1067.80	0.00
159	57	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-54 kg.	50.000	1100.00	18.00	55000.00	0.00	4194.92	4194.92	0.00
160	57	61	SFRC Concrete Manhole Cover 32" X 32" ,MD-116 Kg	10.000	1800.00	18.00	18000.00	0.00	1372.88	1372.88	0.00
161	57	62	SFRC Concrete Manhole Cover 18" X 18" ,MD- 25 kG	50.000	650.00	18.00	32500.00	0.00	2478.81	2478.81	0.00
162	57	65	SFRC Concrete Manhole Cover 15" X 15" ,MD-21 kg.	50.000	450.00	18.00	22500.00	0.00	1716.10	1716.10	0.00
163	58	65	SFRC Concrete Manhole Cover 15" X 15" ,MD-21 kg.	5.000	450.00	18.00	2250.00	0.00	171.61	171.61	0.00
165	59	68	SFRC  Manhole Cover 24" X 24" ,LD -41 Kg.	2.000	1400.00	18.00	2800.00	0.00	213.56	213.56	0.00
166	60	56	Igloo Tiles 12"x12"x15mm thickness,3.2kg/No.	2500.000	47.00	18.00	117500.00	0.00	8961.86	8961.86	0.00
167	61	59	SFRC Concrete Manhole Cover 24" X 24" ,MD-51 kg.	9.000	1500.00	16.00	15660.00	0.00	1080.00	1080.00	0.00
168	62	52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	1000.000	300.00	18.00	300000.00	0.00	22881.36	22881.36	0.00
170	63	52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	1000.000	300.00	18.00	300000.00	0.00	22881.36	22881.36	0.00
171	64	52	kerbstone L-450mm X H-400mm X W-100mm.Weight-42kg/No.	1000.000	300.00	19.00	300000.00	0.00	23949.58	23949.58	0.00
173	65	52	kerbstone L-450mm X H-300mm X W-75mm.Weight-24.20kg/No.	1000.000	210.00	18.00	210000.00	0.00	16016.95	16016.95	0.00
\.


--
-- Data for Name: quotations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quotations (id, quotation_number, customer_id, proposal_id, status, valid_until, notes, total_amount, created_by, created_at, exchange_rate, state_of_supply, discount_amount, round_off, billing_name, billing_phone, billing_email, billing_address, billing_state, delivery_same_as_billing, delivery_name, delivery_phone, delivery_email, delivery_address, delivery_state, gst_type, tax_type, is_interstate, subtotal, cgst, sgst, igst, approval_status, approved_by, approved_at, tenant_id, sales_executive_id, customer_billing_address, customer_shipping_address) FROM stdin;
45	QUOT-0011	27	\N	draft	2026-04-30	\N	10500.00	15	2026-04-17 11:00:26.95511+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	8898.31	800.85	800.85	0.00	approved	5	2026-04-17 11:00:27.536+00	1	15	No - 27 /1051 Sri Ram Nagar, First Street, Ellichathiram Road, Vazhudhareddy and post Villupuram,\nTAMILNADU - 605401.MOBILE - 9944663674, 9843430086.GSTIN - 33ACNFS4904N1ZO.	No - 27 /1051 Sri Ram Nagar, First Street, Ellichathiram Road, Vazhudhareddy and post Villupuram, Tamilnadu 605401
47	QUOT-0012	30	\N	draft	\N	\N	253800.00	5	2026-04-18 06:23:51.763191+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	215108.12	19345.94	19345.94	0.00	approved	5	2026-04-18 06:23:52.355+00	1	5	Shri Suresh Timbers & Tiles,\nGST Road, Tambaram Sanitorium\nChennai - 47	Shri Suresh Timbers & Tiles,\nGST Road, Tambaram Sanitorium\nChennai - 47
48	QUOT-0013	30	\N	draft	2026-04-30	\N	268200.00	5	2026-04-18 06:33:14.156677+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	227288.14	20455.93	20455.93	0.00	approved	5	2026-04-18 06:33:14.734+00	1	5	Shri Suresh Timbers & Tiles,\nGST Road, Tambaram Sanitorium\nChennai - 47	Shri Suresh Timbers & Tiles,\nGST Road, Tambaram Sanitorium\nChennai - 47
50	QUOT-0014	32	\N	draft	2026-04-30	\N	129600.00	5	2026-04-18 10:31:09.348504+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	109830.51	9884.75	9884.75	0.00	approved	5	2026-04-18 10:31:09.98+00	1	15	Karaikal Nagapattinam,	Karaikal Nagapattinam,
44	QUOT-0010	10	\N	draft	\N	\N	3540.00	15	2026-04-17 10:52:43.644535+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	exclusive	f	3000.00	270.00	270.00	0.00	approved	15	2026-04-17 10:52:44.065+00	1	16	Tiruppur, Tamilnadu, z:641666	\N
24	QUOT-0003	11	\N	draft	2026-04-25	\N	13000.00	16	2026-04-15 09:42:55.673144+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	inter_state	inclusive	t	13000.00	0.00	0.00	0.00	approved	5	2026-04-15 09:42:56.218+00	1	16	Tiruvannamalai, Tamilnadu, z:606702	\N
21	QUOT-0001	12	\N	draft	\N	\N	22500.00	16	2026-04-15 08:33:01.293621+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	inter_state	inclusive	t	22500.00	0.00	0.00	0.00	approved	5	2026-04-15 08:33:01.846+00	1	16	Thiruvannamalai, India, z:606705	\N
23	QUOT-0002	13	\N	draft	2026-04-30	\N	35000.00	16	2026-04-15 09:39:21.744549+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	inter_state	inclusive	t	35000.00	0.00	0.00	0.00	approved	5	2026-04-15 09:39:22.314+00	1	16	MALLASAMUDRAM, TAMILNADU, z:637503	\N
28	QUOT-0006	14	\N	accepted	2026-04-30	\N	45000.00	14	2026-04-16 02:35:46.994575+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	38135.59	3432.21	3432.21	0.00	approved	15	2026-04-16 02:35:47.575+00	1	14	Thiruverumbur,Trichy.	\N
25	QUOT-0004	15	\N	accepted	2026-04-30	\N	120000.00	15	2026-04-15 10:21:39.634315+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	120000.00	0.00	0.00	0.00	approved	5	2026-04-15 10:21:40.205+00	1	15	Billing Adress:\nRC-Construction,No-20,anderson road,ayanavaram,chennai,600023.GST:33ABAFR9373G1Z2.\nShipping Adress:\nRC-THILLAI,7th Cross Street,Thillai Nagar,Trichy-GST:33ABAFR9373G1Z2.	\N
27	QUOT-0005	16	\N	sent	2026-04-30	\N	795000.00	5	2026-04-15 10:56:21.240988+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	no_tax	f	795000.00	0.00	0.00	0.00	approved	5	2026-04-15 10:56:21.786+00	1	5	NO.40A,  MICHAEL NAGAR, SANKAR NAGAR, THALIYUTHU, TIRUNELVELI-627357.	\N
33	QUOT-0007	22	\N	sent	2026-04-30	\N	160800.00	16	2026-04-16 06:45:24.315955+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	136271.19	12264.41	12264.41	0.00	approved	5	2026-04-16 06:45:24.893+00	1	16	Billing Adress:\n19th Cross St, Village High Rd, Sholinganallur, Chennai, Tamil Nadu 600119.\nShipping Adress:\nSolar Power Projects,\nMudukkur,Tanjore,Tamilnadu,	19th Cross St, Village High Rd, Sholinganallur, Chennai, Tamil Nadu 600119.
51	QUOT-0015	33	\N	sent	2026-04-30	\N	225000.00	5	2026-04-18 10:48:23.353331+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	190677.97	17161.02	17161.02	0.00	approved	5	2026-04-18 10:48:23.964+00	1	5	9R7M+QR8, No 13/A1, GH Rd, Chalai Bazar, Ramanathapuram, Tamil Nadu 623502	9R7M+QR8, No 13/A1, GH Rd, Chalai Bazar, Ramanathapuram, Tamil Nadu 623502
53	QUOT-0016	34	\N	draft	2026-04-30	\N	1100.00	15	2026-04-21 05:26:46.148359+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	932.20	83.90	83.90	0.00	approved	15	2026-04-21 05:26:46.16+00	1	15	SRI JAYRAM AGENCIES\n214 Karur Main Road,\nMulanur -638106\nPho": 9842797995	SRI JAYRAM AGENCIES\n214 Karur Main Road,\nMulanur -638106\nPho": 9842797995
54	QUOT-0017	35	\N	draft	2026-04-30	\N	7000.00	5	2026-04-21 06:13:43.783911+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	5932.20	533.90	533.90	0.00	approved	5	2026-04-21 06:13:43.795+00	1	5	Sooriur ,\nTrichy\nPho: 9381031440	Sooriur ,\nTrichy\nPho: 9381031440
55	QUOT-0018	35	\N	draft	2026-04-30	\N	7000.00	5	2026-04-21 06:24:48.223665+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	5836.11	581.94	581.94	0.00	approved	5	2026-04-21 06:24:48.251+00	1	5	Sooriur ,\nTrichy\nPho: 9381031440	Sooriur ,\nTrichy\nPho: 9381031440
56	QUOT-0019	36	\N	draft	\N	\N	96760.00	5	2026-05-02 07:53:44.917918+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	exclusive	f	82000.00	7380.00	7380.00	0.00	approved	5	2026-05-02 07:53:44.929+00	1	5	TRICHY NAMAKKAL MAIN ROAD, TRICHY, THOTTIAM,TIRUCHIRAPPALLI,621203	TRICHY NAMAKKAL MAIN ROAD, TRICHY, THOTTIAM,TIRUCHIRAPPALLI,621203
59	QUOT-0022	39	\N	draft	2026-05-30	\N	2800.00	15	2026-05-07 04:17:26.569554+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	2372.88	213.56	213.56	0.00	approved	15	2026-05-07 04:17:26.578+00	1	16	Batlgundu \nDindugal	Batlgundu \nDindugal
60	QUOT-0023	40	\N	draft	2026-05-31	\N	117500.00	15	2026-05-09 09:29:56.581497+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	99576.27	8961.86	8961.86	0.00	approved	15	2026-05-09 09:29:56.592+00	1	15	Plot No 20 , Seethapathy Street \nAmirthammal Nagar, Lotus Colony , 01st Sreet\nMadhavaram, Chennai	Plot No 20 , Seethapathy Street \nAmirthammal Nagar, Lotus Colony , 01st Sreet\nMadhavaram, Chennai
61	QUOT-0024	27	\N	draft	\N	\N	15660.00	15	2026-05-11 03:51:07.517346+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	exclusive	f	13500.00	1080.00	1080.00	0.00	approved	15	2026-05-11 03:51:07.525+00	1	15	No - 27 /1051 Sri Ram Nagar, First Street, Ellichathiram Road, Vazhudhareddy and post Villupuram,\nTAMILNADU - 605401.MOBILE - 9944663674, 9843430086.GSTIN - 33ACNFS4904N1ZO.	Mr.Karthi,\nManikandam,Trichy.
62	QUOT-0025	42	\N	draft	2026-06-15	\N	300000.00	5	2026-05-15 11:52:24.390033+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	254237.29	22881.36	22881.36	0.00	approved	5	2026-05-15 11:52:24.399+00	1	15	72nd floor Janappachatram Kiribati nagar,Chennai-67	72nd floor Janappachatram Kiribati nagar,Chennai-67
57	QUOT-0020	37	\N	draft	2026-05-30	\N	142000.00	5	2026-05-05 05:23:04.779875+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	120338.98	10830.51	10830.51	0.00	approved	5	2026-05-05 05:23:04.812+00	1	15	Vellore \nPho: 9894807318	Vellore \nPho: 9894807318
58	QUOT-0021	38	\N	draft	2026-05-30	\N	2250.00	15	2026-05-05 07:36:51.966743+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	1906.78	171.61	171.61	0.00	approved	15	2026-05-05 07:36:51.975+00	1	14	14, Gandhiji Street, Malaiyappa Nagar\nAriyamangalam, Trichy- 620010	14, Gandhiji Street, Malaiyappa Nagar\nAriyamangalam, Trichy- 620010
63	QUOT-0026	42	\N	draft	2026-06-15	\N	300000.00	5	2026-05-15 11:56:57.475487+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	254237.29	22881.36	22881.36	0.00	approved	5	2026-05-15 11:56:57.485+00	1	15	72nd floor Janappachatram Kiribati nagar,Chennai-67	72nd floor Janappachatram Kiribati nagar,Chennai-67
64	QUOT-0027	42	\N	draft	2026-06-15	\N	300000.00	5	2026-05-15 12:03:28.270087+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	252100.84	23949.58	23949.58	0.00	approved	5	2026-05-15 12:03:28.28+00	1	15	72nd floor Janappachatram Kiribati nagar,Chennai-67	PSN Construction,Vellore.
65	QUOT-0028	42	\N	sent	2026-06-16	\N	210000.00	5	2026-05-16 03:50:16.691263+00	1.0000	\N	0.00	0.00	\N	\N	\N	\N	\N	t	\N	\N	\N	\N	\N	intra_state	inclusive	f	177966.10	16016.95	16016.95	0.00	approved	5	2026-05-16 03:50:16.7+00	1	15	72nd floor Janappachatram Kiribati nagar,Chennai-67	PSN CONSTRUCTION,Vellore.
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens (id, user_id, token, expires_at, revoked, created_at) FROM stdin;
1	1	0b949548527d6bb0f32a9db0eaf66371cc8eb8f871169733d77e870f364ec01b7f29009ca370f3ce	2026-04-08 05:25:28.128+00	t	2026-04-01 05:25:27.721455+00
2	1	6fd492211229eedd408151c55f2274931ad145d9e04c20ccc5ec1c4a23f36eb607c1dc5c65399dca	2026-04-08 05:25:31.792+00	t	2026-04-01 05:25:31.386098+00
3	1	07e6b2e52da5fb04ec611427da2b1fd21e2bf014978ddd6beaff826d2b42de93e3aefc8477e77348	2026-04-08 05:25:35.759+00	t	2026-04-01 05:25:35.356501+00
4	1	3f2d70f19fc36ce7f69a50d0f91b3783e817dd4cdaf685caa9a573cb4b3da9eed6a95eff7f529476	2026-04-08 05:27:10.204+00	t	2026-04-01 05:27:09.811324+00
5	1	a8f04c3eb39f1ba43d6285975335eba0b8cbf421f94dfad2b357f0a83dee94f444f88ede75bea658	2026-04-08 05:27:13.676+00	t	2026-04-01 05:27:13.281289+00
6	1	3d658c40043a7a2792511b5bb514ed2cdc543c4a21fce26d32fa2da9a62c7c0c45119e71e54e6a2f	2026-04-08 05:28:10.956+00	t	2026-04-01 05:28:10.551833+00
7	1	1a5069749c15229ba5f5d1c8908c99e3f4324a6fca85dfa72a016c55116f5ca8fbfb343297e68ba9	2026-04-08 05:28:39.055+00	t	2026-04-01 05:28:38.655556+00
8	1	6d33989cfc0118d276bd3a68908c2a1a1cdbc74be0653a1ac4decc0f974e5d8465c8cfc056c2a840	2026-04-08 05:28:42.791+00	t	2026-04-01 05:28:42.386641+00
9	1	65544c13bbf0492710191d63a3d073180adec8e94ea173cb303518649239ec6b4086076e03043741	2026-04-08 05:29:00.485+00	t	2026-04-01 05:29:00.081734+00
10	1	729398da27e2239fc8c17135185a4457eeabffe17549e32aabdaf997c9e251cbbffa184d9904f080	2026-04-08 05:29:10.05+00	t	2026-04-01 05:29:09.642164+00
11	1	1710b2cf32d4eb70b236366c9c9d490b3c7147fe130d768f7b7015a0f40a81e30f40962178ebcca8	2026-04-08 05:29:13.771+00	t	2026-04-01 05:29:13.371077+00
12	1	805f822f6f404df173506485e07c484c7fdad6d0cee581dbf5933cd772344eacf63220fb69043fd0	2026-04-08 05:29:39.058+00	t	2026-04-01 05:29:38.656031+00
13	1	96dd03cd99441b1b16674b5e8ef80e4ff7693f70394bb419e9ba6fe227ff0ae16e16e30a7ee7973b	2026-04-08 05:29:46.934+00	t	2026-04-01 05:29:46.54191+00
14	1	2d59a5ae1d48eba700b93c1823d7d0e5acc03bedaab033f8bd63e98751d8e355cdf1b8d4cbeef6ed	2026-04-08 05:29:50.503+00	t	2026-04-01 05:29:50.106067+00
15	1	324813d171cbb79a88514ed9c234f6b76b15ff87d3bf7432b45928cc496486959a44a696a35b173e	2026-04-08 05:30:20.469+00	t	2026-04-01 05:30:20.071698+00
16	1	b269904ca783881ac148fac04a454a872166a3c2f8bc250e6ee3a53d4ce369ea2b85031c3720f5f2	2026-04-08 05:30:24.076+00	t	2026-04-01 05:30:23.67729+00
17	1	092856ef27477455a996f41319d82a33d49bbf316face2e4a961c6ea28718ee6d1308026516fdba1	2026-04-08 05:30:30.039+00	t	2026-04-01 05:30:29.656384+00
18	1	1e64d6deee466ff96a00c08b453736bf999f4358954f60018124a1bf9f43ee0f3acf71dc98e3cd0f	2026-04-08 05:31:13.794+00	t	2026-04-01 05:31:13.391922+00
19	1	4f6e68c0c2aeece48fbec741a768d5d7692ee5b6f842d1fe32da10dddf079aa208834752e65e1222	2026-04-08 05:31:18.053+00	t	2026-04-01 05:31:17.692285+00
20	1	4615608739895aa4941def671c06294006f70c84c4dd14bdc73286810351a69ec890571dd71945b2	2026-04-08 05:31:22.675+00	t	2026-04-01 05:31:22.301905+00
21	1	ba87d1a3f3e670d3e0d08e2ad506afa2ea35eef880081b949476bd6d70f757f8c97977930a20e355	2026-04-08 05:31:32.415+00	t	2026-04-01 05:31:32.022106+00
22	1	28b80546c6c06f3dc9977fe1a8a3b538ececd799d17508a34f36305fd42af43517d9bd4c2d5c4818	2026-04-08 05:31:35.773+00	t	2026-04-01 05:31:35.381666+00
23	1	56ece5152c018c87de7a13b8bfeff8f4f5c6873f76fcd19db4d244537d9d5484bbdf5fb0f666dcef	2026-04-08 05:31:44.283+00	t	2026-04-01 05:31:43.891613+00
24	1	4a65d1f4182ddda4701485dcc8031d9a0a9483f813378f8bab7a128c6e779f10f25fcc994a73b307	2026-04-08 05:42:27.167+00	t	2026-04-01 05:42:26.818094+00
25	1	791cd7a10a367c9669a38cdb3df50f36bdfde65471fbd72b43cd44855f3abb40c3b7f68b447cbda0	2026-04-08 05:42:31.065+00	t	2026-04-01 05:42:30.69853+00
26	1	09b31f491d2d14bebe3fd31b9dcc4741429f76c066e92305252523a0dd8ea9f4e27b7e0673e753a4	2026-04-08 05:43:50.83+00	t	2026-04-01 05:43:50.459789+00
27	1	4499f867a0d1c6c7cdb6a386452bd08fcfdf5e986969a2fdd8e54f823324da8c59485aaf8bc06ad4	2026-04-08 05:43:56.416+00	t	2026-04-01 05:43:56.039432+00
28	1	67c781b5ac28609b8a204e8553e71272a8236f9ccc06125e8cfa9983a813f6e32e37b3664ee928c8	2026-04-08 05:51:57.536+00	t	2026-04-01 05:51:57.150734+00
39	1	2703e1129401cf0555a5a26740bb41b6e49853aa5cbbedbe64ced9a0a90901de3107a82f6ab7088b	2026-04-08 11:42:34.851+00	t	2026-04-01 11:42:35.020844+00
30	1	c581286616216af5484b634ac857f07511d0b902cbe5a818bf2c216e09eddf60cc2f493ff6b01fa0	2026-04-08 11:33:57.349+00	t	2026-04-01 11:33:57.544975+00
31	1	f142b004be47a384aea491ed48b4951ba2bb56049c49f57c0a3ab50026b5adaad5ca94aa523efc1a	2026-04-08 11:34:02.214+00	f	2026-04-01 11:34:02.414843+00
32	1	40cbc4b7b229ba50f3d5cab21b329f94245497c2f684e63f2508f26f7609cccd1046ea02117ec7db	2026-04-08 11:34:02.248+00	t	2026-04-01 11:34:02.445133+00
33	1	77686916d340243692caa73343c1105918f69097b635ce45b4959098c4cfa132edba465fbd2facee	2026-04-08 11:34:06.079+00	t	2026-04-01 11:34:06.274699+00
34	1	65c387e3cbbe4497ffb292353a2b3373bc8bbb3c4595afd84c20a1386a674914f4e6bebc45ad3043	2026-04-08 11:34:37.087+00	t	2026-04-01 11:34:37.280102+00
40	1	bfbd5fa30b9e63c7632677da6ae004b21aa99e6f831276600084050e08c0839d4a348bf00c225fc6	2026-04-08 11:42:39.633+00	t	2026-04-01 11:42:39.806853+00
35	1	efef62694d5029e7d96202e189eb45c6992f602f214f9d4ad7b02e4ad16d75a29c9012699776dbd8	2026-04-08 11:35:18.313+00	t	2026-04-01 11:35:18.503663+00
36	1	73fd92104c8ada75e20ff2c868f61ed5c8ea87cd8dae65f2cf505d9da7ad0f077de122494e928589	2026-04-08 11:35:39.109+00	f	2026-04-01 11:35:39.295033+00
37	1	7413322a5ba8bf82bcd98b4f46b618de57da4f05edc6a248d43a904f3301f895a85ba187849edd3e	2026-04-08 11:35:39.264+00	f	2026-04-01 11:35:39.464551+00
38	1	a0293574ff5be3d3568b9a2413c5338c193950afac1608af1d855baac5d0590bd6fc0b3ae85646b8	2026-04-08 11:35:39.261+00	f	2026-04-01 11:35:39.464498+00
41	1	a48b35a05e6c49b8e3271098ddf03894f83f0c9470b198099547e606dbfb87fe311b72d3c80fb8f1	2026-04-08 11:42:43.377+00	t	2026-04-01 11:42:43.557183+00
42	1	208ec09e0e15670634e7218499f9f9dad9d2672e80050c49c92d9ccfeb84bdd112ecb9449627026f	2026-04-08 11:43:13.823+00	t	2026-04-01 11:43:14.001279+00
43	1	d5283faabe6128215f8c7aee6fef04c2b14cbb766798291bfc6dec74352673ea5c48a53bdb4b3967	2026-04-08 11:43:34.536+00	f	2026-04-01 11:43:34.705648+00
44	1	b86686ec8c3925e3ad3ecc8ac63b6b5f5432b4330908b573f27a64383c4db5a62c03c5276870bf02	2026-04-08 11:58:35.573+00	t	2026-04-01 11:58:35.774423+00
45	1	8322fa439114a68b29cbf00be5247e1cefd42b71de145d2afaef55b480003b898d20b59dc100982b	2026-04-08 11:58:40.093+00	t	2026-04-01 11:58:40.315287+00
46	1	950d94b5f953c8d81d249ca870d94d4e18aa35b8ecc53a2128b5809db8c33613eedf66a281309ad6	2026-04-08 11:58:44.187+00	t	2026-04-01 11:58:44.402874+00
47	1	d9f7ab4b53237c14af1b9200adccfa875ecb5b848de9d676a4953f83da5f060be3a815a9c18b5c38	2026-04-08 11:59:05.817+00	f	2026-04-01 11:59:06.034459+00
29	1	f8b9a67adee81f847c17dc58d7eff63b0d4765cc38f8b8f3612c25ad4fdc099b4c75badcfdde6b8a	2026-04-08 05:52:02.161+00	t	2026-04-01 05:52:01.771326+00
48	1	282fa237865c6e3edc38646e7b9297e61d8261e8e1065568065e6087b4e0ca31c27c8d05fb88e126	2026-04-08 16:14:24.201+00	t	2026-04-01 16:14:23.856058+00
49	1	2b3d70b8e993b388eb456eff464db1999833844ad25a1bd6ad8c7fe18b3111cabc4692d285bd94e0	2026-04-08 16:14:30.15+00	t	2026-04-01 16:14:29.801145+00
50	1	8b7a75044b37f660bd766e7ab5c362e9946299e319bff76e85cf3301b26cdf8e0009673a0d1a4d9a	2026-04-08 16:14:36.714+00	t	2026-04-01 16:14:36.386205+00
51	1	ccb6c45f38f395cecf8ea8489b61804d4816c476b6e2e817411401f2efd3d3aec481fe01ee1a525c	2026-04-08 16:14:40.557+00	t	2026-04-01 16:14:40.216163+00
52	1	f4ef68751fb7132fb491a83e4ef20d632b24dd35018e46661dca9035d3760951f9f4dc93ada955b3	2026-04-08 16:14:58.411+00	t	2026-04-01 16:14:58.076196+00
53	1	eaeff6843a090df8c22ea5ec01ce5e7eeeb4e858d235663f706a6c5fd7597455e29902d35b3548d9	2026-04-08 16:15:06.788+00	t	2026-04-01 16:15:06.456299+00
54	1	279f62e61545dda46f1d1d974897b58120274ca9a5aac502017ad288097275000fe049bfe9c96e7f	2026-04-08 16:15:10.43+00	t	2026-04-01 16:15:10.090306+00
55	1	28e343468caa36f24b84c60b286373cc1c0b128110779ef9786b3f7fc55855bee00c897087cfc74c	2026-04-08 16:25:27.633+00	t	2026-04-01 16:25:27.335103+00
56	1	56367a9f30d38ccd04f603c3f8b3d65ef726a6fceb371af09dbb33fd3673f15af9d7d2a163015b83	2026-04-08 16:25:34.738+00	t	2026-04-01 16:25:34.42368+00
57	1	ec4cd4fbab9151ab6c4728de5539f03cb1b5869a4c83f116646cc751c0fc8ef64a4c2b9bf82068fb	2026-04-08 16:44:09.045+00	t	2026-04-01 16:44:08.731129+00
58	1	ba2ebc3135f4c299e6f2a9f49666910d8ddc1f7ba78cdaab4266714f752779bae73c3aaab62f90f1	2026-04-08 16:44:19.518+00	t	2026-04-01 16:44:19.206938+00
59	1	297433aa2478e75ae862f15539ad7162eff34618dfdc867755c449c62f12ca953807404e9835a9b7	2026-04-08 16:44:57.295+00	t	2026-04-01 16:44:56.976949+00
60	1	8ba086ff14084cfd6c0a9a2e0b0b11c49a621961baec512f96c9beaaef31c1ff356a264b5d5345b1	2026-04-08 16:45:02.813+00	t	2026-04-01 16:45:02.497115+00
61	1	87887476ceaa791217f693a3124a7c6743a5c6bff2cbc442d4298a91d27a719fd6d2c26e4836ad8b	2026-04-08 16:49:11.99+00	t	2026-04-01 16:49:11.715668+00
62	1	dfa4997b38efb37aee3dfde5dd9dfae03b124d7d1f419e387c798a69659c71538429ee58b1457373	2026-04-08 16:49:17.655+00	t	2026-04-01 16:49:17.374072+00
63	1	b4af6032714b9b1d785aabfc9b88f527606274fd7b232008d25cdbc38889ad859c0f62ce220d366a	2026-04-08 16:49:42.739+00	t	2026-04-01 16:49:42.445079+00
64	1	e0cd74d085b19846d7fa0de89389e9a49fbf57fcef421758db9d34edcd5c524d1237e34dbd1f9214	2026-04-08 16:49:48.622+00	t	2026-04-01 16:49:48.314795+00
65	1	f25a41b8e61e8dc46e30107793e8486f7b4bb55764ef7b043334911ade129b4e76f1afdbfd9f9948	2026-04-08 16:50:02.32+00	t	2026-04-01 16:50:02.03361+00
66	1	8ef136381221b43cbf986a09da1cc0a56737da22e27e072f39525f38ce4751d36dfc7c1e46c070ce	2026-04-08 16:50:07.792+00	t	2026-04-01 16:50:07.495339+00
67	1	668c4d7d441674f897eba0e7cb1a481e2e5100578612235d04668f018c1cb389df3a9880a5cddedd	2026-04-08 17:00:07.499+00	t	2026-04-01 17:00:07.18627+00
68	1	cfd00400f093eaaca16122660434a79d51edea82da04cf99440a26443636a0156aba49c4cc905111	2026-04-08 17:00:12.677+00	t	2026-04-01 17:00:12.365935+00
69	1	119cc43621833aec996e72143e928a44884682bd24c4b333ec41b940252912bca40a44a6ebdd76cf	2026-04-08 17:07:27.579+00	t	2026-04-01 17:07:27.279401+00
70	1	dc915cd15d0bf4d493f9b3b7a6d6fd5fb58324c9f267b27c35a11894325987603114414a5527de33	2026-04-08 17:07:58.322+00	t	2026-04-01 17:07:58.044294+00
71	1	fd76b9fcaa92341f27ed5b7809951fbab5632619044bb1ef814d401f16526dc7c5753ff934dadbc5	2026-04-08 17:08:02.742+00	t	2026-04-01 17:08:02.46451+00
72	1	1af062b9db2ff23c9f3f293cef95f5120df2abdde30316a117f931b2f7334e569eb6ba9fecaf925e	2026-04-08 17:11:49.642+00	t	2026-04-01 17:11:49.363756+00
75	1	888ce31e42e6beec4138cd88219504eb94b38a72498a4aa0219a6306b23bf5e0b9c88e0a78ef1b65	2026-04-09 05:49:29.814+00	t	2026-04-02 05:49:29.933922+00
76	1	28a68efc209a4f91c22eae192bc776b240a5f8f08153c2621381215e1c2e47a1fc4eb1d10bddcf18	2026-04-09 05:49:46.032+00	t	2026-04-02 05:49:46.150381+00
77	1	c2dfafad228ce20c55861b7a58a95f4bf73798c653ba2f46df4dc9d20a1ab10f911567cec53fcfdc	2026-04-09 05:50:01.69+00	t	2026-04-02 05:50:01.813052+00
78	1	1f1e4aa0947fc2c83fae4ac26258e39e31623a7a92a6a1a0449bb1b8547463bcb6337df8bf93497e	2026-04-09 05:50:05.223+00	t	2026-04-02 05:50:05.347085+00
79	1	ffc4f451dd88b996eb6d1073e73fddb4c29058852b2b1e84f2df2b39e3be0c5bd350f0ef7b841b39	2026-04-09 05:50:14.4+00	t	2026-04-02 05:50:14.529828+00
80	1	bf87a65c40617531a0b36eca5cf6f0a6c0484d3f899ae6db01d1f4a3581adefd5ecf2ba73b686a79	2026-04-09 05:50:17.831+00	t	2026-04-02 05:50:17.954352+00
81	1	54c0027ed9102fb26040eebad82d6b1cc184062e0ab7418ab438761fa118abd2a4044ad50272f9ce	2026-04-09 05:50:25.458+00	t	2026-04-02 05:50:25.576205+00
82	1	3f7c8d3bcd37694eb2f8390f3cf9a76aa7e48a984db3aa4145aaf1320d20d60e367ff851eff82a57	2026-04-09 05:50:34.97+00	t	2026-04-02 05:50:35.087423+00
83	1	96c78c4029e700e1c54e15ab03c72c273f40c3353094a0b19639c49349f178b3c75a6fa1ec25a5f5	2026-04-09 05:50:51.547+00	t	2026-04-02 05:50:51.666232+00
84	1	22b07a2caf5e5a53370b964fdb143c7315cae96858f61fc1fba2d35fce34072460ec990fa2f65d04	2026-04-09 05:51:01.934+00	t	2026-04-02 05:51:02.067762+00
85	1	ce516a235e3f3c342a0221866ccded9808688a4a693b938e5876e0d58c7cadeb5ce98c287c1c7e11	2026-04-09 05:51:08.398+00	t	2026-04-02 05:51:08.531137+00
86	1	136d317219543b4d207389af3882e9c879fec3142358fd500ee0a83b75dbd17d8e13fe4fe98718b7	2026-04-09 05:51:15.93+00	t	2026-04-02 05:51:16.063209+00
87	1	4b797e4d0e08b8fe0447cbbd1408bf1f3e6bd9b0f25464e46f0701c19c65ce459c5638771813bdb2	2026-04-09 05:51:19.938+00	t	2026-04-02 05:51:20.060906+00
88	1	754384951925959188179e7c4ab100f706ec4c57622169f705a7fd578de302a46acc75b6fc7f6a89	2026-04-09 05:51:24.039+00	t	2026-04-02 05:51:24.163123+00
89	1	715b0ba40f15c47f9a7a37b3e6e97044e67f0734c3d972f45628708f3fad8b02ef16f941d2859e96	2026-04-09 05:51:40.268+00	t	2026-04-02 05:51:40.385435+00
90	1	42508bca9c8f8f7ef9ec923868c9521d4298015d014029c86aa136905a68ffd5090e2ead18330ee2	2026-04-09 05:51:49.198+00	f	2026-04-02 05:51:49.314787+00
74	1	86111af433558d9cb25cce37a1e7e8dfdad846053e38093134dacdb17e2e119de13d6034c7bce7f3	2026-04-09 05:41:08.25+00	t	2026-04-02 05:41:08.37838+00
91	1	dcad6ac4b1e074e55513e950dd647c314c7600f8220501393e5c01d2b881792565a59147a34d06b3	2026-04-09 06:15:46.628+00	t	2026-04-02 06:15:46.752418+00
96	1	383bc36531d6059971b50b5907fdb2deadf7adefdb6de924ce472da9a26a980e669423aa04fa1f17	2026-04-09 06:32:56.529+00	t	2026-04-02 06:32:56.663294+00
93	1	e6b80aba5450316d4b9292ef99ed9a62b2e114be869f05dcfb37879a51205ba7446e008c14e1c4c0	2026-04-09 06:19:46.957+00	f	2026-04-02 06:19:47.085656+00
92	1	a837a764f4facb8ac795d4819fc52b88669edf20649ae68739936da890ffe4e4eb6d6d305721340c	2026-04-09 06:19:30.831+00	t	2026-04-02 06:19:30.965013+00
94	1	f9ace7cbe93fdc8b02381ace85ec579c023888ad9f3c9b48a31e2e9f300601a1dc3b79187ebfbed8	2026-04-09 06:32:43.796+00	t	2026-04-02 06:32:43.920034+00
95	1	ffc536e4ab0882e446de345db8707e822d8464f2d14d71f0d3c9c30a5ba08d8c0bdc21eece976275	2026-04-09 06:32:49.03+00	t	2026-04-02 06:32:49.154291+00
97	1	918b5f8071160d7a7b8932c00183602026e5e55c48ff980a1e83b50f9b6f57e2f9646ec2f89de9cb	2026-04-09 06:33:07.308+00	t	2026-04-02 06:33:07.442214+00
98	1	046d76ab286911ff5623c44dd90a86534a89a33487ae4ea40e615394f3561951bbcf3e5f0f53aa55	2026-04-09 06:34:16.101+00	f	2026-04-02 06:34:16.224997+00
99	1	5ed146ab50caa504dda4db746a27d4b950f868e9ad94d5988c846cdd1b2be5f15857594461678dbc	2026-04-09 07:06:48.006+00	t	2026-04-02 07:06:48.134929+00
100	1	113799b97d9b3ab6e2b1a47b5292ad83c3124ae7f2d5298494d744cb64f77d33ad18142615fd4225	2026-04-09 07:06:53.223+00	t	2026-04-02 07:06:53.346865+00
102	1	f3136568e46089d353c9110eba40bcd8ec25c369ba70fd2e8ee9db21d126daf01adecb14a6fcd182	2026-04-09 07:30:45.578+00	t	2026-04-02 07:30:45.696573+00
73	1	a4fbb0ecc59ec53df5c6b71d1012f5d77c1dee5267317352348da507913ce7dfaa41f8d5a009c66f	2026-04-08 17:11:54.2+00	t	2026-04-01 17:11:53.924986+00
104	1	2048296aeeb7f00dd9a1440d95f5a4270cba6ca235ff97ba5b185b7589aa3fd367fb97892f5f8945	2026-04-09 07:32:08.088+00	t	2026-04-02 07:32:08.086854+00
103	1	3310cd6279aafa84d4b426d408278e7172ee71a9b71c886a5cb609d31b14ac59419568a0d0b97ce4	2026-04-09 07:30:50.485+00	t	2026-04-02 07:30:50.619585+00
101	1	7c403b7ca678bcd51bfede43ebd719bbdad306d2ae66a30a20120ee06e7a681fdec844d119154e69	2026-04-09 07:07:02.378+00	t	2026-04-02 07:07:02.501894+00
105	1	76888290c1603a96570dc71dcb3851297b272805931aa8d6c1d4feea52f4d82cbb3628d1a209a054	2026-04-09 07:32:16.253+00	t	2026-04-02 07:32:16.237307+00
106	1	31c3706de439a93964316cbc4a24d3c5db0cc47693387cc2f54eb7cdbfda86956974a87ebeb27923	2026-04-09 07:32:24.535+00	t	2026-04-02 07:32:24.586991+00
107	1	f2bfd5403fe2bc20f5e1f22bf0480d9021b3a8b0f63456888e8114c29c45612fa59caa76750d1cdc	2026-04-09 07:32:30.871+00	t	2026-04-02 07:32:30.852211+00
110	1	1d0f9d3a5fd419c137716ea239dfdd34ec52e7718f10b28675fc628794dc6748c0b9b05618ba614e	2026-04-09 07:38:40.715+00	f	2026-04-02 07:38:40.728308+00
111	1	a894623fdb08713e75fc8898d8d7b9120a75793a0e0db41375ace14fb646728e4c2b1244f3ddceb3	2026-04-09 07:40:42.992+00	t	2026-04-02 07:40:42.999813+00
112	1	267e43a0ea4f693d830c9efbf31af71c9997e1bf1f064f773d1a3d2638ba22544666e3f42f19034b	2026-04-09 07:40:46.983+00	t	2026-04-02 07:40:47.029321+00
113	1	42319868bd15364656f2a39d7f93d645e92e161ddef340c3781456691db90894df90e9072a3031bc	2026-04-09 07:41:04.308+00	t	2026-04-02 07:41:04.329181+00
114	1	0e9186373327db33953cf04b31ea536c4ba63325fa2ce48497c43f29fa137648ba8ca63ed9757857	2026-04-09 07:41:15.426+00	t	2026-04-02 07:41:15.439415+00
108	1	fdb61f59474d0eea818182a1640c71a44f1048db9441b5eee1e0d89944a5d381424a0da211e3baaa	2026-04-09 07:32:53.734+00	t	2026-04-02 07:32:53.716724+00
109	1	c2d83a72be0d4fb85acd2c8e49a42a5f3d85e63f309ce943e89a73cd81d30842f8ede5e2e8495374	2026-04-09 07:33:19.484+00	t	2026-04-02 07:33:19.477029+00
115	1	bc8ef520b51fbbefa384b7da20b22231319196f37746ab295923b8d303c762b4e9205929be2fd8f0	2026-04-09 08:17:07.653+00	t	2026-04-02 08:17:07.781644+00
116	1	8faa7ba03d5e8a80bef9170d16a12a73e54f8c1bfafdbd1637c6a83c03a9fa7651686f48eeff6329	2026-04-09 08:17:21.588+00	t	2026-04-02 08:17:21.706457+00
117	1	b6496291e4cf19e4c4832d35ae9619d512596eb966520814100f12592cdc79ac599f5f7bb9a0172a	2026-04-09 08:17:30.966+00	t	2026-04-02 08:17:31.084713+00
118	1	195b033ec9e922d23d7cea9a2920fc09ad2e781bd43c5c003b80ef3764e51d4202ec0201d9433832	2026-04-09 08:17:47.918+00	t	2026-04-02 08:17:48.052566+00
119	1	7feece50bad004abddc5a721ff3c80f0261cffce2d872e1a48a177cd15bdd4f7ea2f0522447d545e	2026-04-09 08:17:55.597+00	t	2026-04-02 08:17:55.718046+00
121	1	8069d938ec5b58fcb49d31cb9463a8b0072fba836d4e73a590880f29c8ed789c04866b3aac199ec8	2026-04-09 08:20:46.757+00	t	2026-04-02 08:20:46.771515+00
122	1	1f1abdc2555beaea31a0df2ec986bca2de9c51eb74989d033f2ffc30563382fe28b4452dbd69f75c	2026-04-09 08:20:57.324+00	t	2026-04-02 08:20:57.351279+00
123	1	a89a571a8ce742776b9a33d7f610336f497d54d6ec862d8bb3fedddbecee739f280496c07f3e74aa	2026-04-09 08:21:07.526+00	t	2026-04-02 08:21:07.551652+00
124	1	c8e300d3fe78f885f3fd5c6ba3c51be94494342243b9f05945fd0d8d7db036d0e81c43a405c75b18	2026-04-09 09:19:03.546+00	t	2026-04-02 09:19:03.602344+00
126	1	ae131a2360dc5045d17d4df9f037d183c8796f07974b8046cafbbf6856eef402320ebeca8aefc6e2	2026-04-09 13:37:42.773+00	t	2026-04-02 13:37:43.070154+00
127	1	f858e0ac35e7f2ab177652af7f15bc3e3f2a87eb4fe30422df54814c45100806c7d97e432e0e6c01	2026-04-09 13:37:47.723+00	t	2026-04-02 13:37:48.029298+00
128	1	b7e68adbb2000a2184d5d67121b3230e997d86b3239cdce0673769836d6677e23021dcb80192c278	2026-04-09 13:37:51.557+00	t	2026-04-02 13:37:51.869756+00
129	1	9669c67382eee1d533204a59c6a84cd03e2ed2515ddd907e0d020796b4cb0471249b02b807d96b18	2026-04-09 13:38:19.953+00	t	2026-04-02 13:38:20.261852+00
130	1	f7a75dc78225b558357bf370dbab371021d790297f1e920ec5cd270224bb6a39d71515fb83e5a10f	2026-04-09 13:38:45.203+00	t	2026-04-02 13:38:45.489407+00
131	1	f6333da61507eea0fce42e949faefd24f4663a80c4e5b2e46c460d85fbf32949bd8ebec3be22649b	2026-04-09 13:38:55.273+00	t	2026-04-02 13:38:55.569702+00
132	1	998c0a3605dd2c85a70d0e8a8829bce28c62bad6ea092f41f7e1cd65e2f7629f31e06e2f933bac2a	2026-04-09 13:39:46.63+00	t	2026-04-02 13:39:46.910744+00
133	1	355157725847cb6aa5510dcca7c09a4d85c64cf8bf8ffa75d3d1ac1cf858a1986c5d8dcaa00cc1e9	2026-04-09 13:39:56.529+00	t	2026-04-02 13:39:56.819704+00
134	1	2df7b860502077a1cc1de34112d81de3014932431493e1f7cac8b4784e7d0f27b7e635b8e2b3b9ec	2026-04-09 13:40:01.819+00	f	2026-04-02 13:40:02.11002+00
135	1	b6eb1a6368bd66f9ab3384d3b9f4ed4aa0a7fc7e9ab24643b1a62449adb4417e2bbc0e3730806379	2026-04-09 13:43:44.741+00	t	2026-04-02 13:43:45.017657+00
136	1	df56114311625ffa8a16a6e265661776dbbc6e0ecc89674bafa28fd74abdbec75b578e068263a858	2026-04-09 13:43:54.048+00	t	2026-04-02 13:43:54.321371+00
137	1	d86b6bb84d428d6d29b98344a411249cc30d034fccc246a58412225a93c9f15a1bc62f150d56102d	2026-04-09 13:44:09.506+00	t	2026-04-02 13:44:09.781432+00
138	1	d88ff59f9f36f5f3f702c993a00fc7685b728b3b94239aac9ad34eb0a8263e900ae4f65ec477d27d	2026-04-09 14:06:42.212+00	t	2026-04-02 14:06:42.538519+00
139	1	d5b31f6b7ad58089588f3e8830a7298a4058dafc5913c0b66663057cba1f1033b28129f4b6317401	2026-04-09 14:06:47.418+00	t	2026-04-02 14:06:47.729644+00
125	1	54aa74f1988e9b5d6028b474d2d9305afe2b88f438a91908d9d403801d5df2285ee17ede73d075b9	2026-04-09 12:07:31.524+00	t	2026-04-02 12:07:32.052021+00
141	1	94fdf92f0d817650cb69b44de29aea821734352be79b42954121dab2c06ffa35870bd43a5e93bb25	2026-04-09 14:09:56.967+00	t	2026-04-02 14:09:57.278468+00
142	1	1951aa5fc6736418c98cd4b0e30be419ead3ecfe86f8200299efe5f5d6e719aee97c9aa1f384c809	2026-04-09 14:10:01.327+00	t	2026-04-02 14:10:01.629893+00
143	1	33987829b345ae544833b42c2edf7b25df8efd994b0edfc3db84994fd80cc61e0a89053625a10a4d	2026-04-09 14:11:44.47+00	t	2026-04-02 14:11:44.761395+00
144	1	35e6693dfc980d4c4293bdd2b830d600342d73495a9d6ed227c7d719586c778d46343a7b39c6aca7	2026-04-09 14:19:09.111+00	t	2026-04-02 14:19:09.402007+00
145	1	932fad0f4fc7f0e0bd334d640042d6c0de61434547b9b325352439e6b5cbb0407cd3d856897ae12e	2026-04-09 14:19:13.371+00	t	2026-04-02 14:19:13.678284+00
140	1	826d4d968dadc113eb3f611fc6c4d8dd252cd25b0ebaf15f563c361e3e8c711b2aeea53ad434413b	2026-04-09 14:08:25.033+00	t	2026-04-02 14:08:25.348458+00
147	1	943cc577be2872a249303a980f5ab4abc58c77f68f62e2cf47b71f89730e3517ab47fdd2d451d980	2026-04-09 14:25:16.071+00	f	2026-04-02 14:25:16.399703+00
146	1	9c0bf2de009c853088270b5e2cb6e30479bd5412b26778d7561d8a917cd62922d6a977573d826ae0	2026-04-09 14:25:16.051+00	t	2026-04-02 14:25:16.36977+00
148	1	61425074274c03287f19ef77e7979e82cda452f3a08763111cafdfdc0e6474a78ad92bf2e3df5e65	2026-04-09 14:25:21.156+00	t	2026-04-02 14:25:21.48401+00
149	1	b538740489446f857e94222bb9e30a66da1035a125a1fba37f5042a8a362fe9207268c2b0502a30d	2026-04-09 14:26:24.958+00	t	2026-04-02 14:26:25.279587+00
120	1	8dd75ab30b3d3d95899735fbabec53903d897b489470c73a2d0f94d6b6e903dc628ddbb5e9c8db62	2026-04-09 08:18:00.671+00	t	2026-04-02 08:18:00.79843+00
151	1	b7d66c1f5ff34851dbb6f62a81bd863409a7976ce87e005ea5cfb8fa98a12ca9610788745b9299f1	2026-04-09 15:10:04.175+00	t	2026-04-02 15:10:04.294421+00
152	1	ef9b818be70a82ad97a5c721910a559f1760f88c4fc7277f5006ac7cd9495578a4c249460f9f728c	2026-04-09 15:10:08.242+00	t	2026-04-02 15:10:08.363978+00
153	1	c71b6f6b86e700b605d221e367047c069341484e4b361084095eb13f3bc486e4a745504f015f02ad	2026-04-09 15:10:14.986+00	t	2026-04-02 15:10:15.107051+00
150	1	343460ffba17b22dc9e4e1a9efe08592f2354c14f649834e8e89884ce824bc5e1b1890e5b2516f1b	2026-04-09 14:26:28.776+00	t	2026-04-02 14:26:29.099769+00
155	1	d9cf0aa1fda16adfa6e2f0df1c3c2c33cbad020ec2293a90938fc8475cac8e7697bb8ced6e98bf41	2026-04-09 16:12:44.616+00	t	2026-04-02 16:12:45.119659+00
156	1	57c5a24b8d2f46c4f10f7e1ebc633db2416e8616341b7bdeec129e23e8afdaf2b4e5e8392d5a27fa	2026-04-09 16:12:52.175+00	t	2026-04-02 16:12:52.690383+00
157	1	18ea53f77bf9303b616f4096fd4bd03e3ea114e7a3e6fabf3f0f34f2b1313f230e45040d28aa7559	2026-04-09 16:13:06.637+00	t	2026-04-02 16:13:07.139663+00
158	1	f68a137212467aad50c769ed20a01a73771aa06a0cc6c8e0519cce47cc83074cf66e4695b71c7fba	2026-04-09 16:13:33.439+00	t	2026-04-02 16:13:33.948669+00
159	1	d6736c6994e16e43bb8324c6f7f5dd4673645ce8413d47a3c8377e6388d19375e47533d7b602f677	2026-04-09 16:13:54.698+00	t	2026-04-02 16:13:55.270668+00
160	1	1f1ea0ab978386e370c5c03a9ffd1d9711f897f2b1d485e53c73b25d1035f2b12a0d2fc67bb6aba7	2026-04-09 16:14:03.759+00	t	2026-04-02 16:14:04.299992+00
161	1	bf0300f48c4379c65638a6afd934f1d1c6a85b1b44526d1533e1c10c6af24e45e838e6419653d99b	2026-04-09 16:14:15.228+00	t	2026-04-02 16:14:15.849378+00
162	1	dd8ac77905a4a6acf4856807c902e25cde5ab35964a0e3d02181f87f12cd3b43cbc091e120fd7601	2026-04-09 16:14:41.966+00	t	2026-04-02 16:14:42.469293+00
163	1	9ba6fde1e6d308237941ee1617b0cdef7f05d3072601bb6090a175f302e9ffd1d5db363a50937854	2026-04-09 16:19:27.746+00	t	2026-04-02 16:19:28.259802+00
164	1	22ae392899ff5a0d38517932c1ee5a88396bac3c9e789b7c4adc0e4f2b490d3ef3ceeff5e0f7819a	2026-04-09 16:19:35.802+00	t	2026-04-02 16:19:36.307171+00
154	1	05e7c23c855d02a0b870d040f6e34d41ed9b0e3d11f20f47924d2a00191301dfc83910aa9ef752dc	2026-04-09 15:10:20.397+00	t	2026-04-02 15:10:20.517924+00
165	1	c8d996f3c57a32f6fca01f5157bc42dc9f6119396623589dd758707ee4bf734bbe5b2d002a52a857	2026-04-09 16:20:40.136+00	t	2026-04-02 16:20:40.641603+00
166	1	a10ff553d97c5e5e839c80509e569bd75d9e4f530f60fda307b0c2b22d02b68a4fab7590e10017c8	2026-04-09 16:21:00.633+00	t	2026-04-02 16:21:01.141099+00
167	1	9ae094b9c4bfa8823788e9e313e029ca633379371266db2a0d2ee6deaf249496943c81396284ac0e	2026-04-09 16:21:06.714+00	t	2026-04-02 16:21:07.230506+00
168	1	dcac219faa9f62d654e58fb05821dd7ed0c156059acb172f8f179d448b540d3333561fc5aedf8e78	2026-04-09 16:21:09.821+00	t	2026-04-02 16:21:10.330528+00
172	1	cde0288efc1f0fbe180c277367526ba814b37ab72c0730f88c78a7d37529769de9ab4542fa1959c9	2026-04-09 16:27:29.105+00	t	2026-04-02 16:27:29.608531+00
173	1	651d225e5e2c92ddfa3ed7eecdea20785e21edb2ebf7cc836bc8d746d2c2c90cdc584547c9809219	2026-04-09 16:27:35.548+00	t	2026-04-02 16:27:36.061912+00
174	1	c7459df41796258340046b76fc466f414f4fc1d457912b9e1a574d436028e18928909084a76e485c	2026-04-09 16:27:42.246+00	t	2026-04-02 16:27:42.777553+00
175	1	594ee1c5fa06136b70f049971a87a09d11de79b73be175cd0e94aeb6308369084f0525c65cffbf06	2026-04-09 16:28:29.93+00	t	2026-04-02 16:28:30.438166+00
176	1	b17d3b12ee98515262bb9ca2d126f478afb55cd6e479e94447fef109005b89670176f7d7c1f4b6a3	2026-04-09 16:32:16.434+00	t	2026-04-02 16:32:16.961+00
177	1	c8c1b09d03592e7740576966ec76ecb4379e73ecfbff05c7be11e4bb54dfc26dab0d6b43fadc31f8	2026-04-09 16:32:20.823+00	t	2026-04-02 16:32:21.311586+00
178	1	f0deab682d6d3cd6b6b8657979c0e9fac1696e6dc48f57d665dea05840407d1744cf62f8d4a4f525	2026-04-09 16:33:00.549+00	t	2026-04-02 16:33:01.047708+00
179	1	26a1ed8d17e39b5184962d50adfde9ffbb3d8a29965e377d3603372a84889515e0ae3c4d68d89c3c	2026-04-09 16:33:05.437+00	t	2026-04-02 16:33:05.931175+00
183	1	1cf718a85f97ea6d7766b6e0fa8dc3afe98a9003dacedd656b70015d223011d49217d4014b6603cf	2026-04-09 16:33:36.809+00	t	2026-04-02 16:33:37.317265+00
184	1	7ed333ebbcd32d36d2321389c3f5a5dce4b5754dde481cd83cef5f7311c592ed24c360f868f9acb8	2026-04-09 16:33:39.797+00	t	2026-04-02 16:33:40.297484+00
185	1	47abf963601cbb1f2766817d2fc59f05fce1650fd9c56e28336a569289c7dd9b22cd0000d767b27e	2026-04-09 16:33:42.279+00	t	2026-04-02 16:33:42.77094+00
186	1	37a8c5fca75d61a72345379898c383d906e699d0f816fcac94a88edaf8c5371302b4a9d4f6274392	2026-04-09 16:33:56.101+00	t	2026-04-02 16:33:56.607626+00
187	1	188c87e7783db069cf46517db9343087859d922340cf2bb2004a2cffea812c3b5ddea10c4854461d	2026-04-09 16:34:30.152+00	t	2026-04-02 16:34:30.670342+00
188	1	fe62555a75a66699c535de3d08863f4867f79d358e0d00358108fbe4cbfc9ccba1ceda72c421ef32	2026-04-09 16:34:42.319+00	t	2026-04-02 16:34:42.821515+00
189	1	b193b725abb2781e738fd4b21c990d08733353fb1b45c51ed8317564c321d51a82630a78b0224aa9	2026-04-09 16:34:49.555+00	t	2026-04-02 16:34:50.067655+00
169	1	4ccfeca7e60eb3e336ad070c7192fcdb62e8a3cc259d7ebb452a90587c7c0de2cb622abfc343c5f6	2026-04-09 16:25:52.418+00	t	2026-04-02 16:25:52.932355+00
170	1	2034d72d3e52d4859fe9ef875f6e54327e034e9c194bc2fb0ca1a5cdb854efe2e7eaf0632f3962e7	2026-04-09 16:25:56.962+00	t	2026-04-02 16:25:57.470223+00
171	1	15ca74a477cabe0ead892d33ac8aa1f114d227864c9cd27c6b5184f611a0a40c44fbe0448fc21deb	2026-04-09 16:26:06.407+00	t	2026-04-02 16:26:06.929487+00
180	1	6ec000955f32b62262f25c2690dc87b1bd6310bb269593f8e2d273fb8d09406eba4c596104c95db6	2026-04-09 16:33:09.228+00	t	2026-04-02 16:33:09.727041+00
181	1	d3c4382a3c75037741fbb38880ba149d950fa8cf647834a16c895e4c30e0ba85ac930b4742ea7dca	2026-04-09 16:33:14.118+00	t	2026-04-02 16:33:14.627882+00
182	1	54834ef8f728128a221d9f687fa9b8a18939ce3b250cd368104b4497ff4c29cdf011f274085ce4f4	2026-04-09 16:33:32.713+00	t	2026-04-02 16:33:33.211883+00
190	1	86258a6aae1b227c0103f2d418dd1a3f083d205d0e1017d777b44286bfd4f09928d64ca2edca5b70	2026-04-09 16:34:58.636+00	t	2026-04-02 16:34:59.148018+00
191	1	c562b830c3d492b59feecc80adc5108e0da76c6ef121033ce0ec19541fc869daffaf1bd31ea91ea1	2026-04-09 16:42:36.807+00	t	2026-04-02 16:42:37.321095+00
193	1	3ebaeb1a248deaa63de236a8443d4bdcd35009a841267a95754739ee1c48b25beaef8c681ff408e9	2026-04-10 01:41:54.322+00	t	2026-04-03 01:41:54.448722+00
194	1	9c50b9a0195455e61e31a8183d330d4ac4d4760193391b016dfb493f5d762d5c00637b42d16907c3	2026-04-10 01:42:05.679+00	t	2026-04-03 01:42:05.812799+00
195	1	fcc70567325d3492bbe65b882c26f1e24cd873964bf9b77cc32803bc3c71a6a043a4ac4aee2b7480	2026-04-10 01:42:10.1+00	t	2026-04-03 01:42:10.222259+00
196	1	85fe5cd41849d0a6ab4316318b8b741a96d89f8f59482c4d25a02c85c85c5f28f00ad5476651e0d6	2026-04-10 01:43:37.903+00	t	2026-04-03 01:43:38.015374+00
199	8	e08d2bbc66826634d4489819236c8d907b1c9b94fdba6ba9b2f6b6584fb5caac2d2b36597e88c78b	2026-04-10 05:52:34.988+00	t	2026-04-03 05:52:35.979896+00
201	8	7183f72c4f33ebb6843c4bf748cbcdcac75416870505142b30760f450b63fafbf16f278e6fda8f72	2026-04-10 06:10:18.494+00	f	2026-04-03 06:10:19.49066+00
202	1	284bff6ede029a1e9b4856b222f30863bb659a6586cd803acd1daedb6bbbe2ab4f0e834c490af539	2026-04-10 06:20:36.207+00	f	2026-04-03 06:20:36.319722+00
200	1	9c4e282a62b460dff0e90482d140fe65663d6cad83f853eb7804db81f6a287d60a725f22a3f0bb2e	2026-04-10 05:57:30.69+00	t	2026-04-03 05:57:30.802412+00
203	8	5af1b6b6b208b8106ad41f457a9160524e519c606d61406b509a0c945b57b9f3bf87e75e65338881	2026-04-10 07:18:45.759+00	t	2026-04-03 07:18:47.151028+00
205	1	6e79e40d5ac41ee2b672f0b1b60f54a61c42442c18fe900b442414aac6042d36161456fd2d8c7963	2026-04-10 07:39:13.832+00	t	2026-04-03 07:39:13.943874+00
207	1	38b3691ac54e8f2709dfa073bd122cbc17bbec2c9d20209c004b0503dc50ff7d8f957dc7f198d3e8	2026-04-10 08:38:47.084+00	t	2026-04-03 08:38:47.196399+00
211	1	ea3073b99e008c94853920e1b1a981f4fe955f240895e7fb1ee3356fcb7f283d4d22f4ad945a57e8	2026-04-10 12:02:43.023+00	t	2026-04-03 12:02:43.134919+00
208	5	9ef58d6a6c82413a7e4e4ef8b206fbc8084858df1bbd12d6cf602cf390b6bc6d4d2b7c8fef7f57b8	2026-04-10 08:42:03.507+00	t	2026-04-03 08:42:03.61875+00
192	1	7024a3a1d9eefc69ab862a516e998323c2fb4a80a0f8e808e63097f02a43b88db3cdda9c75638e05	2026-04-10 01:32:20.479+00	t	2026-04-03 01:32:20.746301+00
198	1	1179bac523536661ae3e5f436d485e386df8e3c6edad27fccd29fcbdd03eeab504cf5c4663b15610	2026-04-10 05:31:49.857+00	t	2026-04-03 05:31:49.968551+00
212	8	b70884e2b9cf1dcc0ed6120946a4cb11e3b133b22c9c904ec018c27d37261f8611bcf12f4f7d285d	2026-04-11 11:23:22.065+00	f	2026-04-04 11:23:24.023924+00
210	8	cf49dc072f5a525ba015da5fc19011e6582a164534795c0d4b4c59d84ec82acdb195c627172f6db2	2026-04-10 08:47:48.629+00	t	2026-04-03 08:47:48.741242+00
214	1	8f8630e324383e9510d414c780a0109b448db106084a836ce703f7983c7c6a80aa542763a6ea4a97	2026-04-11 13:21:27.23+00	t	2026-04-04 13:21:29.052442+00
217	5	d2297a0a0b30617a14d340af48e3e1b9a3400ec34285743eabc20a8a54c02a440f284ff4198407a9	2026-04-12 04:31:16.953+00	f	2026-04-05 04:31:18.611878+00
218	5	cba82d45a844bfcb2e3d746b3c004dd3661e29cfeada22439a2aec6c6da830127457ac212f089bef	2026-04-12 04:51:33.223+00	f	2026-04-05 04:51:34.915637+00
216	1	3acae6d842d57b85c08cfd7619a9f058eb5473b61aaeb2259502a7c71899f0bb47e189c2e86896c1	2026-04-12 04:24:07.132+00	t	2026-04-05 04:24:08.782289+00
220	5	9c3a1fd2c66f87713093fe623d825c2acbe17c271bf094788d7e3ff95f6b88b8f61a6f6743b18c8b	2026-04-12 06:13:33.336+00	f	2026-04-05 06:13:35.492451+00
221	5	ddd200b14677554ccfcb4c30f8c51903e57a0d6e9485fd7456ac77706c966fb6cd8ab7ae9451fff4	2026-04-12 06:22:26.177+00	f	2026-04-05 06:22:28.362238+00
222	5	335ee71fb183e8017c544869b4ca9e0391518e3a1779a167ed423f407485bf84128c3140d3e74922	2026-04-12 06:39:33.891+00	f	2026-04-05 06:39:36.093703+00
223	5	93d789582c1eb72f1d646ab913ddd9e71ae35032e07fccd523eb53e8b3126dee43742b9df254f340	2026-04-12 06:52:04.54+00	f	2026-04-05 06:52:06.746228+00
224	5	c22d4ec7a45812b55161299d490c2047730b8336ea02015224dd028d221f8bac4a56a727afac1964	2026-04-12 07:05:08.576+00	t	2026-04-05 07:05:10.79226+00
206	5	5b04725d33cd93591e551ce8a323bf37b6a6e742158e7ac69d14d40b873a05077c728a1059afc227	2026-04-10 07:42:08.58+00	t	2026-04-03 07:42:08.692128+00
225	5	a50b0bad39aaecffe79ebb552df14cbab07113452ee85c3b94a78f5b484c6c38e654ab942a925712	2026-04-12 07:37:46.444+00	t	2026-04-05 07:37:46.565817+00
226	5	9cac8094c9d7aa95b430222b2c85212f965bf5aeb44f1bd5165bd896a33883e6a0f44041f6592eaa	2026-04-12 07:38:26.661+00	f	2026-04-05 07:38:26.79066+00
197	1	95146f114f68d939acbb6cf7f8cbe631d79552e0775d1e74aa97904e07461033b04c275444a557fc	2026-04-10 02:45:20.721+00	t	2026-04-03 02:45:20.836679+00
227	1	04e42631209bbe4cf6dd30d05899b9ad49151fd3a07d5e3562c12563c14acd248ff12e60d4c9aed1	2026-04-12 07:43:30.277+00	t	2026-04-05 07:43:30.403689+00
228	5	de5feb53264226a0c5a3ed30c69be88868306a4b45c21094df037e884f58085e0c1dbd00980b7c93	2026-04-12 08:13:24.219+00	f	2026-04-05 08:13:26.493382+00
229	5	19cede98f0fcf0bcbe9ebbde15273a2c686a6a432eea0a52daa07d40b98a95edabf9e3cd24218904	2026-04-12 08:28:56.474+00	f	2026-04-05 08:28:58.716644+00
230	5	c434152ad83efa6ebdca16a65d2280feb8de358fde62e0819e829b5e260cd8ca0e805d0cf0fff1bd	2026-04-12 09:28:49.323+00	t	2026-04-05 09:28:49.450108+00
232	5	6ace5545fb3531c3854f881b29da6ea095e80b5ebeb0aa08402f54718b20af410fd33ba6aaeb75e1	2026-04-12 09:29:49.928+00	f	2026-04-05 09:29:52.575464+00
231	5	9ed0a9621bb5c47a9279092e368c32449b7c6b456d2b6972e2491ca65d310e8f16e0fe75eb9dc8ff	2026-04-12 09:29:25.856+00	t	2026-04-05 09:29:25.973505+00
215	8	29698886cbc7939846de90e9fd5db0a0ac6286e4f539b07bc5e75a311f11c4a29b981361da3a200c	2026-04-12 03:34:50.987+00	t	2026-04-05 03:34:51.097992+00
234	8	6ebe67cfc2324da241c9222de28205fdc09c853f01dffbe27348ffaa57d479c7142d72da0350751c	2026-04-12 09:42:04.778+00	t	2026-04-05 09:42:04.894718+00
236	5	051f83a2ece55fb2e5576392bc86ec141e683726c0d5200d0c26cfdf4ed35f807f598779723d68f5	2026-04-12 09:50:32.062+00	t	2026-04-05 09:50:32.188676+00
219	1	bc5b164aef9c1717929429f6b8a9999004ac1a8a8267ea2783dbfe880e700f22555007c5e7e15095	2026-04-12 05:50:41.777+00	t	2026-04-05 05:50:43.944846+00
237	5	c47cdc2540b647bc462f6e4cb8a3143fa96e7ec61119b24033ae71fbdc7a0d8ed7f3558c8963eebc	2026-04-12 09:56:45.36+00	t	2026-04-05 09:56:45.481515+00
238	5	e49bf9376e84222c5c75cc80d8a61b5a679c28e4763d322f6699c5ada9ff5ca2b3b79daf49dc9878	2026-04-12 11:07:00.357+00	t	2026-04-05 11:07:00.480887+00
213	1	d57343ced720c6a1287404bc89d9da43b094d64567149a79e6cecab6bb0722d0d0e44d8064ac75fb	2026-04-11 12:33:54.945+00	t	2026-04-04 12:33:55.060475+00
233	5	9fe73deaeb9c8c1b6e8f92f7a9989c367d4cef0e4a0fd82685a21dd95ef21ea27476b1e4b45d09cf	2026-04-12 09:40:48.657+00	t	2026-04-05 09:40:48.774645+00
235	5	45b312251b06ebe13bcb97e2802b84a66f920437cc8fe76f18b88a9d6761644d12686e4a2728934f	2026-04-12 09:49:07.672+00	t	2026-04-05 09:49:07.788454+00
241	5	c35b0f26c05e13a5909c9acdf309cdd9b68ad4e55d336a5feb5da70903184952b15c3d879b244143	2026-04-12 12:04:14.646+00	f	2026-04-05 12:04:14.762393+00
242	5	a5782cb72dbcfba9c85c1de1d120b3d979e4fcd0ed15e9077c27797815c54ef9d732f978cbd057ef	2026-04-12 12:08:07.48+00	t	2026-04-05 12:08:07.596+00
243	5	b63a851bc44837b188cf7ca85890fb8479a2297a1c1eb690efceb5ef5f4add2a2e2c78f76b91a864	2026-04-12 13:12:24.634+00	t	2026-04-05 13:12:24.745848+00
245	5	a82d49f97a0d45f048b0967041d8019a8d836eb7ae532a0f1ac5c9a151d9f5632a74d74150e9b2be	2026-04-12 14:50:12.31+00	f	2026-04-05 14:50:12.422198+00
244	5	d2fce4f2142ccba365237b8fdff5eb3e246a6fde7271abb88b8f34eb82f513b00f201401dbc0d7b0	2026-04-12 14:23:50.942+00	t	2026-04-05 14:23:51.05419+00
240	5	b201bcca3e0620a4c078461ed9074e972496d15b9202093927d43c6989f4f578a55752a2ac926bea	2026-04-12 12:02:33.79+00	t	2026-04-05 12:02:33.901982+00
247	5	ef6e50e1a76902208c44cb11c5be6db7d52c61d965b83746b0961bc26ab04a24162303c0970ff8ee	2026-04-13 07:21:47.553+00	f	2026-04-06 07:21:47.665327+00
246	5	8eae1b5949044f9a0785c89a8b0a4269c3f5ad41110a0ca19bc2ed68dd6d524dd9275573b6ccab95	2026-04-12 16:34:16.231+00	t	2026-04-05 16:34:16.343591+00
249	5	dca27424f741eac36504cc3d09a4a0f94382fa5e21701d44344ae7315ab0dcbc5f235bbe5fd5269f	2026-04-15 05:16:58.552+00	t	2026-04-08 05:16:58.664609+00
239	1	888be502f74517a672ef0f06ec3f029a000e653c61b0d57e0a18b6f189441287ed0a0ce8e23b4614	2026-04-12 11:16:38.338+00	t	2026-04-05 11:16:41.036723+00
253	1	00d6001a7d0ab4899b803a9019a36543c32f25c5896d0857f0ef0cf47e54549a6928c7adec29853f	2026-04-15 15:43:00.283+00	t	2026-04-08 15:43:00.214553+00
256	5	58afaa5e09932921d2afe8b5ff72bf71b7e015451103c81d87e77e1c1d1aaeff9efb0d5c7611565e	2026-04-15 17:46:15.813+00	f	2026-04-08 17:46:15.809842+00
254	1	857e80bbfb439a62974a8f852c6c60ced5794784f62b4d2c090e30bd65c2d3f820f4415950fb5ea6	2026-04-15 16:48:03.228+00	t	2026-04-08 16:48:03.194185+00
258	5	034cec2a31cd460b9e43759406dec8f3449d3f53ff8be1082d5a5f7c5d2491f732ff05751d1d63db	2026-04-15 17:59:40.206+00	t	2026-04-08 17:59:40.228418+00
260	8	b833359628bc046fcded67302769203392fdc600db2058aae20dbe7ea6b6d3530b17831905370259	2026-04-15 18:12:25.015+00	f	2026-04-08 18:12:25.042932+00
255	5	acfe55db36d193b0882b52b0128a7b758e12a2c22460803a1d5e3992385cb93887359f1480a2bbc6	2026-04-15 17:24:43.833+00	t	2026-04-08 17:24:43.992201+00
252	1	a5be2d4331706e46de389390ff8fa19e9992b1add1dacb79e0e3ba45ecffa2ead5b482cab86ef65a	2026-04-15 13:33:12.894+00	t	2026-04-08 13:33:13.006503+00
257	1	476914b541ccf2ca49bd78ce385d98d1661f213747fe83fd2739021746003713e170b9a648ba00d7	2026-04-15 17:48:08.381+00	t	2026-04-08 17:48:08.393829+00
265	5	a7cb5305397e9601b4956cbb70d26842a367870ec8ace2930ac059adb67f7b50e54fce13573ccdd1	2026-04-16 01:02:49.518+00	t	2026-04-09 01:02:49.442694+00
266	8	7c02a7404aee7c644a0a7d5b596c90fe14e6235ce755178ce0fdf7805f14692b73b98dc0e587d801	2026-04-16 01:04:56.564+00	t	2026-04-09 01:04:56.489418+00
267	5	0e82e682d4d5c8fa7a118c41ed2aa36e891553ad652ec34851bef7675d85692319c3031e2f164764	2026-04-16 01:07:25.968+00	t	2026-04-09 01:07:25.867312+00
268	8	122628be23b434beb4c5775f5a25b68eb1b65c75c6cd567ed135ce969848c179d583e2df7e5db165	2026-04-16 01:14:42.107+00	t	2026-04-09 01:14:42.044353+00
269	8	c1c41d834bfa0d65a0b43e61c028b3610dad40d3387aa7806985d5535887b397e64fd6bafed60014	2026-04-16 01:33:17.337+00	f	2026-04-09 01:33:17.303222+00
270	8	1f9b327e28b9d1646a1d02068dbfa96aa0e4e39d642370664820bc8230a03d75ba667cf0cce6fa30	2026-04-16 01:42:18.028+00	f	2026-04-09 01:42:17.984576+00
271	8	9b8408da96216e8d20be45ea75d4fc9d322f4dbbdf6368dacea7c5a777143113542436924003dde7	2026-04-16 01:42:25.549+00	f	2026-04-09 01:42:25.49405+00
272	8	d2d4c860fa147f700205c13b3c6bbb510fba9926a1a5c56079fd27fd45e60492244104abe53da7c5	2026-04-16 01:42:34.541+00	f	2026-04-09 01:42:34.483925+00
273	8	285b4e44b1fa43558a4129f46a5153ad02ea7e6de7ca336afd6b08a0ae7b704bf88329d1910ea065	2026-04-16 01:42:41.73+00	f	2026-04-09 01:42:41.673929+00
274	8	1b912362beba873b016f70915bf7229faa93591a90d139145641e251c68e64c71965c4fb3633eaba	2026-04-16 01:43:07.521+00	f	2026-04-09 01:43:07.464888+00
264	1	37d12ac82dbea62717bd71321a2b17649b7c0ba75749ac33eac11bc27ad3b74e1c80e544d4f22c13	2026-04-16 01:00:47.463+00	t	2026-04-09 01:00:47.478591+00
276	8	1a8024a6529260633d72bc8106de00d88968e990ba0f484fdfd1c596a7f8061497f6b84c82e53292	2026-04-16 02:03:59.061+00	t	2026-04-09 02:03:58.534411+00
277	8	13dd0897e2869a2b7b6c8d9ba56efdd70042363770e15a515343b35dff70f5727dacbc43ff90f1da	2026-04-16 02:05:45.195+00	t	2026-04-09 02:05:44.656022+00
278	8	73fd3e374954d5dc7e3d9177046bc762901d51a53bb5113ddeba0f99b024211891b8270e500886bc	2026-04-16 02:07:20.541+00	f	2026-04-09 02:07:20.013336+00
250	5	b4ef5213ea940ae8a05136ca7caec7d7ae8e1e1a013a20934dfb1d1b7f06a46e79226f6ef28b6704	2026-04-15 05:33:27.594+00	t	2026-04-08 05:33:27.705536+00
262	1	7f5dbe4303b44dd1a29bea8d883646a00a95a0388bcb63ae730f66a4418c5615f740ba1abfe6e3d3	2026-04-15 22:19:19.848+00	t	2026-04-08 22:19:19.960873+00
282	5	786ba6155de50d566af0b33e02ef75e67adcc66374deb47f2b2a38a70576b52163f24c700f2ecef3	2026-04-16 03:55:55.521+00	t	2026-04-09 03:55:55.637091+00
279	5	2548f88762432d45d0a36edd2aa427eaa2c3995f5ab08d3a99abaef329f276ac91cf986ac5d44661	2026-04-16 02:25:31.093+00	t	2026-04-09 02:25:31.208514+00
261	5	9ef1bda31857d4d8ae1dcddc19a75836ff5cf447585c1808850aa3d8c41b4239e04d653d4187bd37	2026-04-15 18:26:22.347+00	t	2026-04-08 18:26:22.5082+00
285	5	67c125b3650a2a5f6401808ac0fb954a1839c8c133b06d5e8c17f5753ccb087a0be254870ce85a65	2026-04-16 04:39:18.631+00	t	2026-04-09 04:39:18.225653+00
287	8	67923fa6cfbf377d64991d083c45e581b8b7b6596f556bcb08af19352c9eacbebfe24f58aa8dea11	2026-04-16 04:50:55.535+00	f	2026-04-09 04:50:55.119042+00
251	1	82288b2586d545b8d5e3c45d2ae392dee38a07ace458b03697662003cd24e9afc14a45c0db2e692c	2026-04-15 07:00:01.656+00	t	2026-04-08 07:00:01.768334+00
288	1	f06a940c45b99a02b76492224bbcdb7cb7dcb329dab1c764c32e71658266383deb51ff8a6a370b38	2026-04-16 04:57:41.612+00	f	2026-04-09 04:57:41.727312+00
281	1	ab7e310e7eb29fd3a8403b21cde7033539023ab5d94d75624ea1e098e7058393e5c87add79e790ca	2026-04-16 03:54:02.66+00	t	2026-04-09 03:54:02.776066+00
286	5	673651e87d1f510522bb46ac40a285aab80bfd45c440620643cf1e7c1f052edacc2e72d6dbcccfa6	2026-04-16 04:42:40.06+00	t	2026-04-09 04:42:40.268455+00
290	5	6a331e15187d637ae62c1fadd07c3882f9d6095f98c87074306ebe725fd545eb5bc3b6520178ffba	2026-04-16 06:12:02.217+00	f	2026-04-09 06:12:02.399619+00
275	1	cc0ad1e8761d43adb10dd0a533d2a17d9fb2abd28eff5f26c7e9c28a40125948096bf0cfe858866e	2026-04-16 02:03:40.552+00	t	2026-04-09 02:03:40.014534+00
291	1	0585f0bb06fe44dfddcf8b52badd16f48846a0c25c404744d4c0ef7235cf3c6c39e5454e4647239f	2026-04-16 08:25:57.647+00	t	2026-04-09 08:25:57.185126+00
289	1	7d4114486464179e5791d287d6d4ba27677cc0775b3cb9557141be9b1259ed86a79e1c3dd5e9a85b	2026-04-16 05:29:19.065+00	t	2026-04-09 05:29:19.180828+00
284	5	4bab78634120f83e96938f6002e12af2bef4cab7f1c84589fb5e77bd1e0661cb0a3a10f6dafb5e08	2026-04-16 04:08:29.023+00	t	2026-04-09 04:08:29.139312+00
283	8	e6df0a960f952d12022634efee16a490d944e63260b0ab3373aa60ed1abbacf2ca1e505443609866	2026-04-16 03:58:59.369+00	t	2026-04-09 03:58:59.485718+00
259	5	7ca0b1eb951bf535b17551efd680636f35672e3a5692a0ad51cdfb91ecafbdef94ce07f85163980f	2026-04-15 18:08:53.225+00	t	2026-04-08 18:08:53.397332+00
248	5	24faf4f9d164f8e415b806b4223b796a4ef1ee2603cb9f271b37a078e988d67430d9b331a7d3131e	2026-04-13 07:21:48.261+00	t	2026-04-06 07:21:48.372739+00
280	5	f8bd0b45b47530f0073529d12249022d1df750f182175ee6fee88360c1cb4b65ef383fb9bbff3438	2026-04-16 03:22:23.953+00	t	2026-04-09 03:22:24.070125+00
263	5	59868d9abab503494b68e8643f6dc9273ba2e12eb028d91cf548c664766c374957b104b9bdf88c91	2026-04-15 22:20:09.775+00	t	2026-04-08 22:20:09.88712+00
292	1	dc6a6e0832deef1fc2acc04d55dd0c29888cff6cf66559fb417f313fae6759e5c422f9ea03e67965	2026-04-16 10:18:11.208+00	t	2026-04-09 10:18:11.084328+00
294	1	d9abe1eac2312d894d262bea3be125caeda28f7c26868963669bbbe517c67317f2a2c6ab59e180e8	2026-04-16 11:24:32.918+00	t	2026-04-09 11:24:33.030624+00
293	1	2b947419c17fdac103860a1423000e3b3d5c3713dd583daf259f92589af78839484244cff83eb0d7	2026-04-16 11:18:53.556+00	t	2026-04-09 11:18:53.864193+00
298	8	1c550b4f39a8bf6e229f8611aa19e28f3d509d86f5b09984a50b19642efafbd8270adef16ebecb00	2026-04-16 11:57:00.088+00	t	2026-04-09 11:57:00.199949+00
299	14	d7ff4870f7c15f609272fc854e1784a0461cda8ccde24d23e8f873753435069a5a52490b88484593	2026-04-16 11:57:45.552+00	t	2026-04-09 11:57:45.663473+00
297	5	bd80c5d501721c0a2edf10e0166358b411bc4dacb2b9d8d2b7d78321b113c21d825bd7e6c243d331	2026-04-16 11:38:35.503+00	t	2026-04-09 11:38:35.807486+00
301	5	0ab6c362fa02d7cdf9e6c124052e360fd4e762e45c7cc5bddfaa338a18895cb96c1db00dad08c2c9	2026-04-16 12:55:01.921+00	t	2026-04-09 12:55:02.277334+00
304	1	2143b22167c4fba2f0e4926fa735fa8fe10c9d0d6b3e19cd6569d862d912cdcf6c9167c25969f883	2026-04-16 15:04:25.705+00	f	2026-04-09 15:04:25.847495+00
305	1	1f80968dd58b1e5fe6bf78dd6beb731e5b64ee40bfc86a4b021ecc65295200873661327bb40ff897	2026-04-16 15:04:36.454+00	f	2026-04-09 15:04:36.597414+00
306	1	ef2956ad87b4c84a206a65e65b262492e6a89ee1d2709498eadbaa81550efc489d59ed5d9bce002f	2026-04-16 15:04:48.124+00	f	2026-04-09 15:04:48.265058+00
307	1	fb92870f3b5e5a92d9f9d18ec2e8d3b7534947ba7ef411af8826f69eda0371e7b04dbd21d1c98154	2026-04-16 15:05:34.829+00	f	2026-04-09 15:05:34.975406+00
308	1	6ccb48a848a4fb7f28db8bc71598057adaa3fe10020af61ad3ffc33d744b0062dac856555a343430	2026-04-16 15:05:54.011+00	f	2026-04-09 15:05:54.147888+00
309	1	b8702790e64c7655e8dfb0c3dc87fd02d3bbe77cb61686c701eeb706fadab382a2948c3c30ca9a1c	2026-04-16 15:40:55.231+00	f	2026-04-09 15:40:55.401074+00
302	5	3f2bf5f7628c5213468a694a7a53816b2abd32b1f4742caf9271bf7a4c8894541b78f530c326bc79	2026-04-16 13:59:36.022+00	t	2026-04-09 13:59:36.436509+00
311	5	1799ada325dcbaaa8be891f0706670b44f0d145ced8deccbd6b8f6a5b67e954c353244964a4ba724	2026-04-16 15:45:36.787+00	f	2026-04-09 15:45:37.351643+00
296	14	47b88044bfc48e878a590fbbf879f827eed88fee9febe4dc8924e738e854f5e8f53061e6bca1bb8b	2026-04-16 11:28:03.79+00	t	2026-04-09 11:28:03.902308+00
312	14	f89ba6a59d75cf4d3488e7a93162291ec105b97f356f65bc11e59628369b02be1a0faceb05cdb642	2026-04-16 16:00:27.4+00	t	2026-04-09 16:00:27.515342+00
313	5	90556da26920acf0b6056319695a76f09c1e6e55657f9afe96af8be73213730d157672a5669ae359	2026-04-16 16:02:27.825+00	f	2026-04-09 16:02:27.941588+00
303	5	2d084269ffa75befbb45fa4a0e3263c41b6be4989f8cef794536caf80c53d46619ccd7793cf875d1	2026-04-16 15:02:27.961+00	t	2026-04-09 15:02:28.100782+00
314	5	bb734c36d2661a8b818d5554e2623aef5c9bb2d19758b35fdf1aa060f2157fdbc3336f458c3f572e	2026-04-16 17:26:11.718+00	f	2026-04-09 17:26:11.915868+00
315	1	8792be85f29bdbf206cf043e95604b036da5a227c210e08dc3e31b2f48953ee8d5e2a0eb72651335	2026-04-16 18:04:40.191+00	f	2026-04-09 18:04:40.361622+00
316	1	411cbda8f7535efbf3c587a6c519860d3261fc749a5fcb52804409a220e69afe904476733d5de126	2026-04-16 18:07:49.508+00	f	2026-04-09 18:07:49.688406+00
317	1	9aec2d38b014173064ee21a13d3b2a153386088b582ce259b34fc802c425f8da28c45e050e8283c4	2026-04-16 18:08:37.738+00	f	2026-04-09 18:08:37.918056+00
318	5	516f4624883d922111a83c8ce7eb0cdcae4fe59aebaa1272c0f5e42af22d36a019a0de091d14f07b	2026-04-16 19:15:41.089+00	f	2026-04-09 19:15:41.249542+00
300	14	4b9973acd657bfae5b70c0d1b9c4c5182c46887569bb8c402275739555df180f0fe041bdef297f41	2026-04-16 12:00:23.669+00	t	2026-04-09 12:00:23.780487+00
295	5	bc093dd6168fe5aa3089e183fd195049eb66f842cbda84d18a5f6faf960a1425f9264cbad429ae7f	2026-04-16 11:25:06.072+00	t	2026-04-09 11:25:06.18367+00
310	5	9ba70894f19e4c50a28a5a3b655c9672e3a31bf2df5bc98e3ac9d660099cf6b4bab53fbe3b2cac91	2026-04-16 15:43:36.814+00	t	2026-04-09 15:43:37.36617+00
323	8	6c46ed284f9ea8126f687bcb7201bd52ede7fe4489e881cfb9dd3d5b62569b1a7d65a78e28ade51c	2026-04-17 04:28:16.617+00	f	2026-04-10 04:28:20.529954+00
320	14	326ce23f3e57e5b0d2f7d0371a961e446755752cc03b9c37dbf237ee740e9fa3a7006b4b0c5fa401	2026-04-17 03:04:23.945+00	t	2026-04-10 03:04:24.061727+00
324	8	e6d2fecbde28273dccbd68b8a93f7d79c24f3f4e0f4a6f2983a0209d3a661610b3afa85bd1bd5c03	2026-04-17 04:28:17.356+00	t	2026-04-10 04:28:21.049423+00
326	8	08b3e0dee22bc9e683770c1daf275fbd7d20f217110c41ae62912e39657d057f54b5eefc6311af2e	2026-04-17 05:15:49.631+00	f	2026-04-10 05:15:49.587273+00
321	5	64293aa49559f682e455807c60947e78bd357f8eebca71820e21cad236366fd118487e04fcb76d86	2026-04-17 04:04:33.091+00	t	2026-04-10 04:04:33.20308+00
319	14	4d824d6fc093cf7ec0aeabcc7b36e6b66ce4662614ebdecc6569bd94120a88b6a3ecece6b88e2813	2026-04-17 02:59:17.124+00	t	2026-04-10 02:59:17.240087+00
322	5	5ed9322ced24a04054338ae4a4fe5a302c5cb620ecae614e22294a5257ca8dccbd9a8df1ebbc47df	2026-04-17 04:17:19.289+00	t	2026-04-10 04:17:19.186859+00
327	5	5b33ca73dd64744803cb13cdad20e45e3242237e6989c6edc2c15d2d685114b798cd93c33b310db4	2026-04-17 05:22:48.442+00	t	2026-04-10 05:22:48.554699+00
328	5	91d0246a2e5c4460e4fd748e554a400e86f2f4f238849d7c3cd58ac812bce290a895c3215eca5036	2026-04-17 05:26:17.564+00	t	2026-04-10 05:26:17.675648+00
330	5	0a5993cb195d73468affae948e852fb2e39d7a56b7a01668167ef496c2748e4c5241a1173de15ad2	2026-04-17 06:20:03.798+00	t	2026-04-10 06:20:03.799443+00
332	5	46e6ab4a0ce79f13302c6e533390f82df81bf4e43b5e91779b1ed54329032cf99687d75f4151bad4	2026-04-17 06:34:44.607+00	t	2026-04-10 06:34:44.732436+00
331	5	0efdcd61205aa5ddb447db6e91a196f5047f56241563226eb7eada4ecd61cdaf649e728d7f14d3fa	2026-04-17 06:23:52.294+00	t	2026-04-10 06:23:52.406605+00
325	14	10c6da061c6fecd2f30cbc38ddef32ec3123e7444acaaefaf1cbd71442ab6f2a4bd0024740c61745	2026-04-17 04:31:38.072+00	t	2026-04-10 04:31:38.184217+00
333	5	fd77418df5f1712809462ee8c952e5901f29216a9ee178d3f312f1efba1079ac8f3b2cf8602df35d	2026-04-17 08:09:08.998+00	t	2026-04-10 08:09:09.079085+00
329	14	6219012ca9aa03301cadd683444be05aaaa5141ae82f0451942a5dc13af437186860c4f02abc14bd	2026-04-17 05:39:48.08+00	t	2026-04-10 05:39:48.192939+00
338	14	f2b5481a45f6a53ba9e706378182652d50f97565e3bbf7f4b0863217c1c5fdba7613b590b1477c15	2026-04-17 09:17:30.728+00	t	2026-04-10 09:17:30.838919+00
339	14	3826e41083148058b507c3aac34b354272d5baa3d5f50f6ae5f5be68d4fc5ca12500aee9b9b57835	2026-04-17 12:36:37.706+00	t	2026-04-10 12:36:37.818284+00
340	14	802182aa060ac86feee62e998b9070be3b381153fdef82397da3b603578f5503659f68b9f7a01772	2026-04-18 02:12:13.774+00	f	2026-04-11 02:12:13.884895+00
337	5	2ada027fa8784489cee8b6c7765311ca3aa2ba8c1c93400010fa20dd8359932e88db8e687f37f767	2026-04-17 09:09:45.417+00	t	2026-04-10 09:09:45.524298+00
335	5	38c68db49eafa1b8cf88d0786582942565233f3024425c31af668cfeb6b21338047bb7a40362396f	2026-04-17 09:05:48.579+00	t	2026-04-10 09:05:48.690863+00
341	5	f42d90a5598a59c388eb09d774022a7e16c292157e6fa65792bd60b21f1bd493ddfbbca56dcf6045	2026-04-18 03:57:05.354+00	t	2026-04-11 03:57:06.34637+00
343	5	360ccacc0b76da0393ee722c5b1bc382f58da281e10b74098d0d98e68febdd96d762531e2b80654b	2026-04-18 04:26:28.049+00	t	2026-04-11 04:26:29.069635+00
342	5	fd2d0bb4ec0c4cb05d30937dcedaa13a53c66ce963587006d1d6b97579f44b2a9d7beec052148a19	2026-04-18 03:58:46.17+00	t	2026-04-11 03:58:46.281066+00
344	5	5da3d7feff0ed989c6fa244d3f2578cb7039837657818fe8d1317ff095ab2c826661e11dc1567c0b	2026-04-18 05:02:52.775+00	t	2026-04-11 05:02:53.802001+00
336	14	5f7d58f471b0e461b0c584f04d808a66a544617e07ab06d85adb8bff69d5ca1796995b0358cfafcf	2026-04-17 09:07:43.793+00	t	2026-04-10 09:07:43.9054+00
334	5	8f2389f5cb56202e6b3619b49bb9ef519298d1b2df96d5c1a30cb9018a119f341ccd9cdf2d640bd4	2026-04-17 08:37:48.94+00	t	2026-04-10 08:37:49.067163+00
346	5	ae1a5742340672289853ca6a369d9ab37d76fab76636cdecb45e744212b117499a03ea34ec186b7d	2026-04-18 05:27:12.75+00	t	2026-04-11 05:27:13.796109+00
348	5	a6a2823a099fae7baf924dbc9bf7cf37dbf761e733ffee6f4795776043b9585c8ab038f6a44a1abd	2026-04-18 07:21:17.583+00	t	2026-04-11 07:21:17.695932+00
347	5	7ce90327be076d41543510a7f1713d776463c02131bf63e08057e1623fc36ce817db7f93d7bfaba2	2026-04-18 06:27:23.274+00	t	2026-04-11 06:27:24.375746+00
350	5	cccc7fc312cd7eb1a9780428d95cda36653cab3740a58bfb7f3dd94149c29b60fe5b2e568cafa62a	2026-04-18 08:40:05.858+00	t	2026-04-11 08:40:07.0197+00
352	5	f55c011371905df18410a7d0872fd5606ac61d3e5a47f21a44c234d7364ca55cf4866b98371d0098	2026-04-18 09:40:43.244+00	t	2026-04-11 09:40:44.426825+00
351	5	c8909ccf33ff338effc8e8ed68b4f38a39e4a92679eef4efbee3bfddf020e450c231a02c837ac915	2026-04-18 09:07:46.811+00	t	2026-04-11 09:07:48.004498+00
354	5	58f3d7ad784fa71ae57cdef7340f74ecf1371e086e0afc7908c254e3f60dd6ed6d820a366e5cae2e	2026-04-18 10:52:33.438+00	f	2026-04-11 10:52:34.695948+00
355	5	779f74197e59171d02ef933be3423178f08e70e7fb7a63c89a5cd1f1bebbcc1d53d4be0c5791742f	2026-04-18 13:10:51.554+00	f	2026-04-11 13:10:51.670091+00
356	14	0fbea7003df204685dcef336213c99682ac18946327623b3e4755455c0d60371490c50eeaec8385d	2026-04-19 05:43:34.439+00	t	2026-04-12 05:43:34.556478+00
345	5	8cab1ee2feeb0a3022ac390290a55242e4d45bcbc9ee1d20fa8365c3586d2e76b890296a38bc3fa5	2026-04-18 05:11:24.189+00	t	2026-04-11 05:11:24.300558+00
360	5	33e5153463658dec0c14346475ec578aca395cc10b923bb4a59abb11567617b22c4901e1035da2c9	2026-04-19 16:19:35.839+00	f	2026-04-12 16:19:35.256652+00
361	5	7c6b444214294e58709d50e290ecb7f01aba0a04e8a94e20051fe0ee07baef22b5c2e1c6b1d6967c	2026-04-19 16:47:26.745+00	f	2026-04-12 16:47:26.189705+00
353	5	85cfbf5efe17a571c644675bdc6fef56eceb636e13a6f12115d6bd9c1e49ddcf6cf690718d9b0e04	2026-04-18 10:40:52.054+00	t	2026-04-11 10:40:53.299616+00
349	5	a83a919d1100f829776fc1d2b752f14cb8c8876ed825c901e5ea3d47802bf807c2d1929ffbd321ba	2026-04-18 08:37:40.121+00	t	2026-04-11 08:37:40.232499+00
358	5	a9fde7ea31754baaa79d5e6ba987e0155b005c6e7ec1fbc8b1ee1acfd942cc6a3950c1cdc4ed699e	2026-04-19 15:33:27.164+00	t	2026-04-12 15:33:27.283334+00
359	5	bb8484bf9d8d319abc97b912289c3d2b16f4103318f0d80547b885f11b55316b6572257d3fe9efda	2026-04-19 16:12:32.259+00	t	2026-04-12 16:12:32.379617+00
365	5	816b117031b3b2f9cb3f6c2a0073e0a8e86a2aab6cc8409e40f3a777157b7fc7d7fa85a60de5ca67	2026-04-19 20:41:44.886+00	f	2026-04-12 20:41:45.012751+00
366	5	9f85c411b9580271de04f40ae72f1fed58dbd2ba450055ae8ad6b277ac1f6c566fbfd561d3e60dfa	2026-04-19 20:41:49.728+00	t	2026-04-12 20:41:49.85239+00
368	5	902a66be7d8d45894262997c90b84b79023d098f48b850f3097be9e8d34fa3ec9a32b6622d042b3c	2026-04-20 04:10:32.413+00	t	2026-04-13 04:10:32.535343+00
369	8	757d2113918762f74952739d57f590ab6c51a2a8d4f5a9ae9631288f11331734261573728ecce752	2026-04-20 04:13:39.579+00	t	2026-04-13 04:13:39.700948+00
362	5	c2fa4adbd59bcd35609f3101988dd6bb63d0b30db8124d6f1d854546edff552d4a5c694d752f8a64	2026-04-19 16:50:23.507+00	t	2026-04-12 16:50:22.921796+00
371	5	1d9cbe50a54ffc8c62926804dcf085a9cceec04672d37485cdf87415c4dad97585fc6bbac4d32cf9	2026-04-20 06:12:04.887+00	t	2026-04-13 06:12:04.226992+00
357	14	f5dece3d0be6f071d85cc956f2cb9f43e8970d2b8f514ff11fad1a4dfd66a22dc74c66eba6284e81	2026-04-19 14:13:46.759+00	t	2026-04-12 14:13:46.88281+00
373	14	995197bdef890d419869ec5f94748b20dff0e54ade6750d9d06268ea49b555b91d43e7ebd15c12f2	2026-04-20 07:23:34.818+00	f	2026-04-13 07:23:34.937537+00
370	8	e81725a1c2bdccd1ff59e483eb1f0eecbcda998436d8792cdcbeb0afb389772c62e94d22f5c25cca	2026-04-20 05:14:34.556+00	t	2026-04-13 05:14:34.680539+00
367	5	68dde00c36eef19ab0738bddff1aa60a3788d6ba15d77a22d1f42172c73f39fba5c07d24da978763	2026-04-19 21:52:55.183+00	t	2026-04-12 21:52:55.303016+00
363	5	8df7ce38e0f1ba4a6f471a414433ce2fef598d0832aeec030524eeddf611b240df0c5cbed6b4e9f5	2026-04-19 17:03:54.308+00	t	2026-04-12 17:03:54.424001+00
372	5	3fc13f6c213fd16b0965a856bce77a4dcccf93e91c7d08d1fac98f9ec47c7d80a9a72de51047e65b	2026-04-20 07:12:49.611+00	t	2026-04-13 07:12:48.929257+00
364	5	846c82132c5f56130c067cd8d0c6fb34121593a524ed5385018fe09ae92f139fa6d5a695327aabee	2026-04-19 17:08:42.887+00	t	2026-04-12 17:08:43.002845+00
379	15	205e10f1a00774edf7d8fa0f9e7c5daf331adadb438a8e800b3c56b6ac77c446a26a4833150214a3	2026-04-20 08:25:26.094+00	t	2026-04-13 08:25:25.449594+00
381	5	318dcf9f5478f73c2c890bd82652965f34141d6fc1a2b35828d7a9a018ddb9e2af04ca74b78f77c5	2026-04-20 08:29:10.296+00	f	2026-04-13 08:29:10.425575+00
375	5	fd4ae847e901b6de31d9549b128634c281d6d6b85af0f1b7e88cfd1f02d60f2e5db90401df702bcf	2026-04-20 07:25:52.806+00	t	2026-04-13 07:25:52.929641+00
374	8	9eb909053441c3235e1278e47bf74780f45d8c4f26a07f935351973b17a888daa2c1810e73e61d52	2026-04-20 07:24:33.179+00	t	2026-04-13 07:24:33.297864+00
384	8	ec8fd34832262ca83fc3e765965010d0edcfb9df159c96e7e9cae03d24d9f2a19b2485416160743e	2026-04-20 09:27:36.417+00	t	2026-04-13 09:27:36.534266+00
382	5	c7edec0d0c8f05dad6f540c2b55b9a8d1f245ee8a50fc8b061d8f1f81e0b5cda9f00f06f40c8e677	2026-04-20 08:30:31.994+00	t	2026-04-13 08:30:32.111353+00
377	5	9b2366510f25d56b6c3f8ed50d2b9e5d737b777c4f780e3e040f8a5429b00ea7fe2e48a851db5031	2026-04-20 08:01:03.981+00	t	2026-04-13 08:01:04.109253+00
385	5	76d684497d15bba8f146516b53941f7c027d6af496ee7a23171def890e8930eab00446b603bc8aa4	2026-04-20 09:28:58.45+00	t	2026-04-13 09:28:58.573301+00
380	5	beaf242b35244c66e92f38426e42daae7a0e54370bf4a6c8350e75337be2e06352d71495633f019a	2026-04-20 08:26:12.051+00	t	2026-04-13 08:26:11.406925+00
390	5	d596cf925e92158a26bc1f29f1fca13f5ee56e979c868ac2e030b1da89b19c6cd580e6c21b7c99f6	2026-04-20 09:46:28.304+00	f	2026-04-13 09:46:27.861236+00
391	15	fc663d0ea0b6cf04db48441a0f23d5afa224fc2866638b5a37b64d4b39e179e1bf12f15167cc1f3b	2026-04-20 09:52:22.762+00	t	2026-04-13 09:52:22.466884+00
389	15	f3dac9224f199e104f6ba9ad5253a8415bf70a5733e18b1dc6b73f33bcc41f32ecfb918dc5cb91e6	2026-04-20 09:46:20.475+00	t	2026-04-13 09:46:20.60542+00
393	15	cbb9d4e01bc3357314f7a8b2cacf6045985d8e0b5d536626d6e5a0c190ec5207ea246f4d4508d42d	2026-04-20 09:54:22.111+00	t	2026-04-13 09:54:22.23993+00
387	15	d060adb8c49110bb59665687b5e12addec5ec4c8626d004c4ed25b129d35695cca1f7c9e262123e5	2026-04-20 09:42:35.618+00	t	2026-04-13 09:42:35.169033+00
395	15	2b676f798266b0b0fe326ce2bc7cc3d0305bae3d248d95e3974d7b2abd6ee878b201ca3d5d143fe9	2026-04-20 10:25:08.288+00	t	2026-04-13 10:25:07.861097+00
396	8	063191ac2b9a10cc25b290d0d5af3eb35602b942fe1cb190696c7676f869cf85899c7a18315139c5	2026-04-20 10:26:02.316+00	t	2026-04-13 10:26:01.880832+00
397	15	fb8758ad4adf06dbfa69ae3eb85a1eefe75b846e8c62f2861e797bf1592561be734be9366a644a17	2026-04-20 10:27:16.41+00	t	2026-04-13 10:27:16.041044+00
392	5	dea7922d86acf0733a36b0ee93b8eea031c752190a9601b8264f6ffb41f89ba58dec5694f73c09ff	2026-04-20 09:52:42.382+00	t	2026-04-13 09:52:41.941395+00
388	5	5676fb9ed139a6f4551675cb8921bb015ffec0417d898b79326276ea97efece7314e5e08de461ade	2026-04-20 09:43:28.748+00	t	2026-04-13 09:43:28.870387+00
378	5	f5be5f4c163afab7aabb8a187a2a060a83fb41b1d2fec9d4aaa0ebf0a0769fd9ea0c49394e4fc96b	2026-04-20 08:17:41.451+00	t	2026-04-13 08:17:41.570592+00
394	8	4f32824bc2ba7f0e41d2c00f1e5b7de9a98e30e5f70277c065ef5230a885781c6398188c7321f38e	2026-04-20 10:02:35.254+00	t	2026-04-13 10:02:35.387112+00
376	5	c48d0f8da1c559fe8f927ec128d382eae7a13b25e5f312a6c8fc6f028a50d3d72d934549b0587b8f	2026-04-20 07:39:37.907+00	t	2026-04-13 07:39:38.035253+00
386	5	5548ac1e0b75ff585654d315e235b853a80a0c13c85c160fa8df42f29f7bca6bf5d5dc0562c7cd4a	2026-04-20 09:42:27.382+00	t	2026-04-13 09:42:27.505357+00
383	5	a03bbcc7d278790262293417ec25c0375604b9d83ff1dff7ca054cf02765e0b2765e2e0a7c08feda	2026-04-20 08:37:28.403+00	t	2026-04-13 08:37:28.529429+00
398	8	95686e8e756881bd0a199f3df26eabe91405d3c5f0efc0721f8bb0833386bb1ae978549eefb8f70d	2026-04-20 10:32:05.032+00	f	2026-04-13 10:32:04.616341+00
400	8	a37732549d84585c56f79bac91a3c30f19e0e56cfa9fa00422040ce6fc022a687444b4f34e418af6	2026-04-20 10:53:22.494+00	t	2026-04-13 10:53:22.114879+00
402	15	c587ccc198a926293880a89b7d8dc1b0cf74a1c7bf3cc9291e4e672e5ea35bb7dc3b35c42919915f	2026-04-20 11:09:13.765+00	f	2026-04-13 11:09:13.424605+00
404	5	cd45ea2702b3b0e6f6b54845c3ffdb2d315f0ab41691a08b6773bfd3b1b3b691511cc5aae7e41ab7	2026-04-20 11:22:32.772+00	t	2026-04-13 11:22:32.891409+00
405	8	bb3240756f9930a448e121b27ad64990d74ff3a702e5ebe85d0f44faba00a3fdf4c223a1871a1c96	2026-04-20 11:22:58.792+00	t	2026-04-13 11:22:58.920225+00
408	15	38a3f6c4153104228e579c0dfc4d8113201b14861e63c3df36cfb53082c73048628917e3e460428c	2026-04-20 11:42:29.682+00	t	2026-04-13 11:42:29.513945+00
409	8	09df361fabb1d26446541be77352ee5698585cf6e65ebe42e5ef7049d9a37ef51b83647f258c728d	2026-04-20 11:44:22.888+00	t	2026-04-13 11:44:22.721257+00
410	15	3f68ebbd82eb2d790fa2c4ec6598b787bc9cbf755175127659cec7b626d56496495b50d89b36a4ad	2026-04-20 11:46:26.106+00	t	2026-04-13 11:46:25.939802+00
411	8	8ae6321758b317d64ad0b585695913c4c07fcbdb7eabd304fa3710fee65ec2075c8b68c8f6244d2f	2026-04-20 11:49:13.988+00	f	2026-04-13 11:49:13.849186+00
407	16	25c60b9a9968cf98235738b1f8f8d50ebd65f974a4aa952620b0673413f5d14334e84879ff66c50f	2026-04-20 11:24:59.126+00	t	2026-04-13 11:24:59.258664+00
403	5	9db6a660eaab559e06c006d4b76f4e0e9b023060f2cb81cc75afcd0e9cb27e6a787c1ccc349e30f0	2026-04-20 11:14:11.394+00	t	2026-04-13 11:14:11.518328+00
399	5	7060b7c03ad56024516c1c52aceb60609863b4ebedabfa0001863920b0b49c64d3f88eb4a402eab4	2026-04-20 10:53:02.399+00	t	2026-04-13 10:53:02.009485+00
412	5	a9e6136bdfbdfa80d03d0a2d5ac3aea2e22b33cd453ee22b565e8ab6ecaaaa3ab7507c75d2a8c356	2026-04-20 12:22:55.052+00	t	2026-04-13 12:22:55.164139+00
415	5	5952288a057529e1b39c286bd8b90431c207de7444117ce56b955f28db1d01a263e82c639a54a73b	2026-04-21 04:05:14.845+00	t	2026-04-14 04:05:14.964861+00
406	15	03b45015d96face000ed5b3e60d67176f875cc236c76344de8f2f746a39150211729f85aca929e64	2026-04-20 11:23:14.674+00	t	2026-04-13 11:23:14.879211+00
416	5	f1fc3c48bb01a14f051dbfde5e052db4d4756d20a6985876a65710d666a2da45094aad88ce092ca7	2026-04-21 06:34:58.024+00	t	2026-04-14 06:34:58.148129+00
401	5	f82cdb9bb355afb4290ad2ebf4494b860038fae901b01a6ef6c3904d3077c704e5c822d005b58c46	2026-04-20 10:54:49.02+00	t	2026-04-13 10:54:49.14593+00
420	5	e15130505c8f4ebceaa10afa9e73a7abe32880890fb015f392f0368746123396dda2a6b9ce051408	2026-04-21 07:58:23.853+00	t	2026-04-14 07:58:24.209131+00
413	5	ed7ebb2bb01b786494bb48cb0ac555df82d51223c8c595d746713a9b8296ed482d4f6d90e7fec5c6	2026-04-20 12:25:31.456+00	t	2026-04-13 12:25:31.567067+00
422	8	725c513869c7d4dce116cfa2a60e1c935c48098c7aef263905eb218329a59b05d4ea57450f08f748	2026-04-21 08:00:52.226+00	f	2026-04-14 08:00:52.584214+00
418	15	c664a0ad1657d6b8a98358ebaed0cef088622affab26ac450d2f3925bf0f27d426e2e6f6ed3755a3	2026-04-21 07:31:17.682+00	t	2026-04-14 07:31:17.808334+00
423	16	96e3096526e88900d06b6a695e668b9b0b1841b3d0c3287395a46d12d5234f71751a4ef0733d45b3	2026-04-21 08:05:15.63+00	f	2026-04-14 08:05:15.757024+00
417	15	a181514cd7fc5ae331c651c1b41c344dfda17e48a35cb8c0950ebeb5f4f82d315d9e91105b9e0e37	2026-04-21 07:18:02.442+00	t	2026-04-14 07:18:02.560042+00
424	15	882745b707881dc8fd8b11ef7c11cedc7eaea3485b9b217c4b1b2139ca770b90b517174e4a111e0c	2026-04-21 08:05:31.176+00	t	2026-04-14 08:05:31.297723+00
426	15	8abe287081728e77ceab04c49fc3707648a0d01542e5efa7a313c933dabefc2615407150d7ed346c	2026-04-21 08:22:41.198+00	f	2026-04-14 08:22:41.579828+00
425	15	d35f5a974d1aebb528b40bedf7cc8a94e6ec97c43980ce152be209e1b34354d6fbba778ce30078e8	2026-04-21 08:13:07.853+00	t	2026-04-14 08:13:07.965701+00
428	5	2470a5057a5a492dc0aee301867caafa76404e41941e00242dacd36cba418980691f9a53db53746b	2026-04-21 08:28:12.31+00	f	2026-04-14 08:28:12.437024+00
429	15	a6d48ac5a8bdb3f253f1f89425896b58a2e8a3aef8eb2007bf60314b437f628f2eed981d873e70be	2026-04-21 08:28:50.989+00	t	2026-04-14 08:28:51.11314+00
431	5	5bbd390f41d73716eb85619827767dd342a7c6d77544fb5d6b3d2e42eac57563e0c1c9aea7db937b	2026-04-21 09:13:54.979+00	t	2026-04-14 09:13:55.10192+00
433	16	a5c1fd982c12af4be974985281b426f7de0165d643c2e94f5255865c161b7311f96bfe5bb118d42e	2026-04-21 10:45:40.468+00	f	2026-04-14 10:45:40.592957+00
419	5	5b33eef8b74130b29d351ce2d21ff33ab6d77ccc185d18ba0821868964e1c7b99e90a1429345c44a	2026-04-21 07:45:24.142+00	t	2026-04-14 07:45:24.259794+00
434	5	d1742fb32e4deedcb8307144915c9231d4ea132961f2bdb6deaaea6a22d7728ff9aa28c7a21f8237	2026-04-21 10:50:37.804+00	f	2026-04-14 10:50:37.925971+00
421	5	59c93c8d76969486f511bc80c622f4a7aa270490f3b464a395e7227beaca758a00e0639f6f956fbf	2026-04-21 07:59:50.502+00	t	2026-04-14 07:59:50.624607+00
414	5	6a1a9874ca97499c69ab3b4f8c1dfec5bdbb762d1067311433adc04e1389a5c1432ca2a4b23504d9	2026-04-20 12:30:11.463+00	t	2026-04-13 12:30:11.316969+00
432	5	27c561b22fb7d4e9b9f95aa458c696013d8f74c76e80114061435e9b08af5a8fb8cbabcb0ca7ac20	2026-04-21 10:16:22.181+00	t	2026-04-14 10:16:22.305603+00
437	5	d3d5b9314ae595315ecd7456b783ef6a53cacef8ca435f1bceb364ff22f097df47bd8d4d83ec1b2d	2026-04-21 11:17:32.144+00	f	2026-04-14 11:17:32.268409+00
435	5	c0092abb3462702bdd71de8004fc2e99acb5d280137794d4e4a23cea6581855759b53a79f943bab3	2026-04-21 10:59:00.45+00	t	2026-04-14 10:59:00.57613+00
436	5	25ab706d9ccd7ccf9438e65177a872f9c53345f3ee9bc794e1e2698634365505c8fc1eb474d26201	2026-04-21 11:00:55.78+00	t	2026-04-14 11:00:56.148783+00
438	5	afe70a9f7ee7382c4c7dec7a89e712d305b93eecd98b48e1301fc29e7cfb766eb656ac36f8eab168	2026-04-21 12:01:00.965+00	t	2026-04-14 12:01:01.091552+00
439	5	49092b26b6f7cdef42bdec1b8d6f4551296ae39beffe3d3c9688653b0c771899e0886cc8d035b910	2026-04-21 12:01:34.833+00	t	2026-04-14 12:01:35.235304+00
441	5	a365c397991c4da242a11ec9ef8aeb140345e2ad15dc8a4634738cd9fc1a752dc8e669618bf343af	2026-04-21 14:24:10.34+00	t	2026-04-14 14:24:10.51271+00
443	15	9ff86a18af4d586856bc36c555d783a232121748d1e0e5cdecb6226e79348c9bfa23f1039935030d	2026-04-21 14:36:17.567+00	f	2026-04-14 14:36:17.768295+00
427	15	5be39253909c286c2e3650d3ff4762b8bfa60e9b65d18104a1c41119a5b65bc4ddf4e4b5f12a6e1e	2026-04-21 08:23:14.048+00	t	2026-04-14 08:23:14.170233+00
445	15	743a1e52e8265f26e954001b762e98bdbbd0ebc0f5dc5353cc82b87a757dd49516658c025a97e754	2026-04-21 15:06:20.664+00	f	2026-04-14 15:06:20.863694+00
446	15	3d5340758b5471c55f29b21c477c46a21d4dbb757b379084f5e498c1595e1bab2b1ee9346afb8b0a	2026-04-21 16:22:24.753+00	f	2026-04-14 16:22:24.849652+00
440	5	e956df960eda22a93b482a4ea29af4797f6c7944d2798118f57afdcf7d909e724fea75aed0aa8236	2026-04-21 13:03:30.902+00	t	2026-04-14 13:03:31.014468+00
442	15	d7f1ac252fdb241aca1febefdc087c68678a0ccc603bbaa1ee56e4bf908a3318d43b4a7911d9bb08	2026-04-21 14:24:49.23+00	t	2026-04-14 14:24:49.419155+00
449	15	b8468b62db96f3ddfcec6082ca77da1e6d9f7b327ce2938489c7a4dca814daf52ab6af855189ee8a	2026-04-21 16:57:59.906+00	f	2026-04-14 16:58:00.022241+00
444	15	87c475a5ee61383ac7180247add4b4d5586c35927ea9ebf93687931c79af750d2e8ab276a0c1a92a	2026-04-21 14:53:47.174+00	t	2026-04-14 14:53:47.28553+00
447	5	9a608949c394a7a21985f38a1bc7b75359905c42000f6bd81b2f046275049ffcaff4c51bfd474dad	2026-04-21 16:43:00.6+00	t	2026-04-14 16:43:00.711466+00
430	15	ddd59d5fefeb3abd0aa2d93695f7adb3a2fec1794d77476688df722fb48ba7b1a9e0ee62711aeecd	2026-04-21 08:32:07.737+00	t	2026-04-14 08:32:07.854114+00
450	15	58524e06427bfc4dd3476e66e7076e7b0cdce669db179a8ef7f663c0ef8904b2df3bd4f71d789af2	2026-04-21 17:41:22.812+00	t	2026-04-14 17:41:22.931121+00
448	15	71b7d2b3f8617b093f87f41988021caee6ccfe6751d51cbff689626ab22029f0523b920dbde700cb	2026-04-21 16:46:45.443+00	t	2026-04-14 16:46:45.501011+00
453	15	d9b58160389d0c70a9b62474eedc17a2b9fdffbeca54c93bcbd6d60abe6fa6dc8473f0125777f09a	2026-04-21 18:37:06.454+00	t	2026-04-14 18:37:06.573801+00
455	15	c479a4715e4a49b5c9b41bde80b537276bde7b566defce19c9786a0f90f2a84725f178cdf97a000e	2026-04-21 18:42:09.546+00	t	2026-04-14 18:42:09.664014+00
456	16	7acae6b71fc209b04a33b115e85a4f1d254e3ee4b314135d9cb15ef73c6f0d047ac7230f7713f1d1	2026-04-22 02:09:39.38+00	t	2026-04-15 02:09:39.506748+00
452	15	f2b09a9e9b87e64984e6034a351956bcee136aec5b212f7221c01316426de43caf683d6dbced0e64	2026-04-21 18:12:54.529+00	t	2026-04-14 18:12:54.651053+00
459	15	f6c7189f358fe5f8480e48e869c4ead98219e50c76121f10923a654a100d86e93dcaa7becac1318a	2026-04-22 05:06:53.212+00	t	2026-04-15 05:06:53.331424+00
460	15	141e1d12453b12bf9f09497465e6360d41d142375ecb36cb9672d4e7b9619948ddb0643b93ebd7c3	2026-04-22 05:07:17.162+00	f	2026-04-15 05:07:17.283385+00
462	5	10103532366a0c9f7b736ca22547501d0b62cf5c6504006143aca2455069ad29ea5e613b8fb068df	2026-04-22 06:14:18.035+00	f	2026-04-15 06:14:18.153069+00
457	15	f88b0d188c909bdbe4f2a4edb6809a4a5a7f9ef870717a017d3e3ccb7892a38d54b03a698598c625	2026-04-22 04:08:09.632+00	t	2026-04-15 04:08:09.758011+00
458	16	dd85f1ef4a89143c96f7b1684c5e2e295a48d4b9c9e9c2883a12f913b3787cd9f3ae2b7f83666330	2026-04-22 04:27:54.243+00	t	2026-04-15 04:27:54.361597+00
461	5	f6e07eabbf5b2e2e70637f79f2a24bd5c302961592da86320aaac43177c408c6305f85b4f8d3510a	2026-04-22 05:11:31.429+00	t	2026-04-15 05:11:31.548801+00
465	5	86bac17fad54cac00aa89e049545936d73d411be8f48209796167d9d73db0ba531ff3619b5fc514b	2026-04-22 06:24:25.933+00	f	2026-04-15 06:24:26.053976+00
463	15	2dbeb0a8128d649c7a76c4e7a0cb99ec884e91cec5c676b79bd80168c422135de1ddd67b0b2ee9f0	2026-04-22 06:22:08.2+00	t	2026-04-15 06:22:08.322995+00
467	5	4993719d373c46c52689ba587d5a5e0771fb6dade232045d4fe1c860bcdafee2cc31c3c082a8acb0	2026-04-22 06:35:33.942+00	t	2026-04-15 06:35:34.066253+00
468	5	660d5c907fbb12160363e987e2ca65fd5548d151f8e9aec7fc11152bf5c5d10b178d22bca09a4fcc	2026-04-22 07:15:14.943+00	f	2026-04-15 07:15:15.066337+00
451	5	4b03ee7be5fe2deffe8151691e61a7a67aa62b2c5ab0c317dc4d3bbf2a5fc8cc0faab136437e376f	2026-04-21 18:09:38.393+00	t	2026-04-14 18:09:38.506974+00
470	5	5178bc144164b2e5e2596ad9e7d3edec628c2c793600c2e420ee6b80dd39e73309e2d7075c06fc0c	2026-04-22 07:15:22.406+00	t	2026-04-15 07:15:22.529858+00
471	5	0ed931773dcc92ae854d5cc40f3e40ef8c7649c18bc994587ac5543973a7dc6470a56a1ea0ea5a72	2026-04-22 07:17:40.558+00	t	2026-04-15 07:17:40.676952+00
466	5	6f0a7b82651dae6bc1c95e2a1dd2999cdc25b5f8cb5a559091726eaf0495fb453301c8df714d08f8	2026-04-22 06:25:39.652+00	t	2026-04-15 06:25:39.775736+00
464	16	6094b7ade8f2236997f3d0f47e36b93f786d179fa205885fc4fb115474b9b0ec5f5677cb6b001c1a	2026-04-22 06:23:02.563+00	t	2026-04-15 06:23:02.68096+00
475	16	ca3fce5142418b5cc7eee431645dfc513aabb7a2f7322e186c4039996ef236c698c33cb90462dfb2	2026-04-22 07:39:54.117+00	f	2026-04-15 07:39:54.22917+00
474	5	5a9ddd2ef1519d16b6c21fb30cef0089bacd85302fbb29eab51a71f6d9fc6b04d9c410b4ff132827	2026-04-22 07:27:23.851+00	t	2026-04-15 07:27:23.963632+00
477	15	041ba3765e9bc55cfaca453c8dee82c339f8c1a98c956a8587be097ec149a778a96551d529f83699	2026-04-22 08:46:30.154+00	f	2026-04-15 08:46:30.264964+00
472	15	ce3ac4591e3feddbd35363fd0f1da7cb6fcfdec844edf475d9b29f5aae6fd4f5c94c3bc6474f2f7f	2026-04-22 07:20:11.924+00	t	2026-04-15 07:20:12.035639+00
478	15	234f1665a3583a1e6638c88565720d8bb2b53dbe08d3b05e398da6cdb57d7b95dc2354348cd21e03	2026-04-22 08:50:43.328+00	f	2026-04-15 08:50:43.440008+00
469	5	f160bfa273f1d7c6579a1e9bece569c3bf4c26bf7517407d3ec77ce979a4f89b08c5ffdee7b9ae73	2026-04-22 07:15:19.545+00	t	2026-04-15 07:15:19.668975+00
480	15	e7b7c5fd7c69309c9829a7f142674209e0a24b8f1a585cff03a9fd442305f46abd3da5a68b55373d	2026-04-22 09:10:22.603+00	f	2026-04-15 09:10:23.540994+00
476	5	dfadb43fde85efb13a50d65dc9d6cac6f27b965df779c8cbe74017f3b3b28b002bb66e8be3585f3d	2026-04-22 08:32:14.204+00	t	2026-04-15 08:32:14.318801+00
481	5	62d845f58a4416009483078d5d04f1be38cbddb37bf04554c66c7589e2eef82d23b834a5bda5a774	2026-04-22 09:11:43.954+00	t	2026-04-15 09:11:44.905146+00
483	5	f82ad97196bb267841c37fd7b5e0d982807fbee59908afc26adc1bb6aa8d493ce6da43d0d498f2aa	2026-04-22 09:37:52.484+00	t	2026-04-15 09:37:52.60067+00
485	5	71f2fa5a9a2e693fd5be1aab510bb59c1a69bbd18f25d819781d0dc4481d527224abd8328ae58675	2026-04-22 10:40:51.056+00	f	2026-04-15 10:40:51.171771+00
479	5	f885a0de65cc0edbbbd329a6f826fb1422fd6937801e47ad48bb3a84b218b100fc9e167e9295be4a	2026-04-22 09:06:13.875+00	t	2026-04-15 09:06:13.986983+00
482	16	c492650ad1c43b91bfb7ea9121f6ea1bc74a64dcc46e4ddbc9d2bda7f177f37e0ce4ed075f8dfaf7	2026-04-22 09:36:57.026+00	t	2026-04-15 09:36:57.137391+00
484	5	9950fc4098e81faaeab41818e55fae0aeef271cc7be6faa0b36058f839a40d55ff8da9a6fe635a86	2026-04-22 10:24:58.5+00	t	2026-04-15 10:24:59.27319+00
489	15	f54a34826710af771b33910f97c962c73747255550f08ba3fb8b85d0ffd08934fe1475f89b877c3d	2026-04-22 11:52:57.544+00	f	2026-04-15 11:52:58.368959+00
490	15	7dafa6c862421c0144695708c9b4e3dc2c04bad5ec00a72d859fc2c94526fe28bd2bcfae039dfb32	2026-04-22 12:27:22.991+00	f	2026-04-15 12:27:23.1156+00
486	5	47e8756659670a39b74be63e313c59a0ffa4ccabe6d6638379df5293076e34da1ebaf305aa20a003	2026-04-22 11:02:15.032+00	t	2026-04-15 11:02:15.158177+00
488	5	dfdd4627fefcde558fdb04b398636644f1c830058776e14700b32f734562df4f3c552ae89ba67c78	2026-04-22 11:26:03.567+00	t	2026-04-15 11:26:04.381859+00
493	5	78cddb22e9afbfec9ffa8bc37a5c3bb3d31635a1656a46e58c6714116e41f333ad6d7da5a226e3d5	2026-04-22 12:33:25.152+00	f	2026-04-15 12:33:26.036959+00
473	15	01039fdb8694a1a8c6c4c84cb3afc6f0fa0d49084d584d73033b61f3ba6f71a4d1b30a1c228cfdc3	2026-04-22 07:20:14.193+00	t	2026-04-15 07:20:14.30451+00
491	15	b8ef9a95140d6b8892327637908cd78931c3401b6a9d3fe7271ca2fb8e64df1a282c9fff657c18ff	2026-04-22 12:29:11.474+00	t	2026-04-15 12:29:11.595218+00
497	15	cdecf5f07ff694fc906355cccc50ed131d8c4f942dd6338d3243be3d98375ed6bae84267355e932e	2026-04-22 14:03:35.02+00	f	2026-04-15 14:03:35.145334+00
494	15	024ed870eca3e6eed4387e6e1318434178811c3e870ea48b174bb0451c8d92894c1e108b95ed4d6f	2026-04-22 12:33:46.709+00	t	2026-04-15 12:33:46.830307+00
492	5	c5e6ea549a62d573a2fc3e4f6ab70c9a1c27aefc47a3217cba3da6373a84d818667547d18754b754	2026-04-22 12:32:17.905+00	t	2026-04-15 12:32:18.026199+00
495	5	38e89160f4f8544401ba2ad4fd980384a3382249cc6d081b901b9aad8b8e4f553837dce3d35543c3	2026-04-22 12:36:54.085+00	t	2026-04-15 12:36:54.207354+00
500	5	809f0e43866abb9045519b7b064b6a394dbc58f3253758e1be753e606ea8178b342158ffec97faec	2026-04-22 15:48:03.025+00	f	2026-04-15 15:48:03.136947+00
499	5	75bb63bd9d15f9e6e843e5e28d7702f13d697a80ea57413fe76c84812801487290f017fa52f3e5fb	2026-04-22 14:35:33.185+00	t	2026-04-15 14:35:33.309475+00
454	5	6fb598af6ab54e0851969f079fe4d083a4f33f1a0a7d26ef01251307dc7d8031860c940bc79e793a	2026-04-21 18:39:26.156+00	t	2026-04-14 18:39:26.282829+00
503	15	877791bcd6af1692c27e07a220f1c4acfd05157ec1dc4e6a99a357f6f7f64beea5e1f4e174500714	2026-04-22 17:14:24.653+00	t	2026-04-15 17:14:24.774815+00
496	15	cb9f3a9bd7d4f1efe82f2b858d22382f4328930c9fbedb2feb246b4d36390ae50a229a35e3fbae93	2026-04-22 13:50:43.563+00	t	2026-04-15 13:50:43.687194+00
501	5	6da91c8a1d0bde439b8f5d91190ab1903360b33e9c1a590eb144f4ba9e9a89ded8e6657ed039cd6c	2026-04-22 17:03:29.264+00	t	2026-04-15 17:03:29.385036+00
498	15	6465602c976287083d74a538ad3e0997d797e6cb266f051d0940770481ced90a2289162c3f1a9635	2026-04-22 14:14:06.38+00	t	2026-04-15 14:14:06.499919+00
487	16	3917867b2abcb5f9e83a1a9c627bb2a0c888b8165e5c284a7e9a3d62825216e8b4cb72afc2607976	2026-04-22 11:04:36.11+00	t	2026-04-15 11:04:36.230397+00
502	5	763e8b20c60ac78b4894a89c86c36db9320d68a4cf3a596dc60ba02d378b02ecce1e976e3a5a609a	2026-04-22 17:13:26.228+00	t	2026-04-15 17:13:26.34584+00
504	1	4ac336375bed412db71bd25dc48ef713b214c2abf0db37c68cc89656bec663f971d5728179d9ea13	2026-04-22 17:14:43.323+00	t	2026-04-15 17:14:43.43951+00
506	1	31495ebb83d6f8645f6654f3decbf09d6d3ac354034d6570399fd51f2aa15cf45d0fd92c3515dfc8	2026-04-23 01:36:47.152+00	t	2026-04-16 01:36:47.272329+00
508	15	c625a6d69d0efc84f7ad5fc22214f6a4e1671ead5173a75be53c6cd0bd550f091c138f5f5e7c8a65	2026-04-23 02:03:46.456+00	f	2026-04-16 02:03:46.60452+00
505	15	9bdd3f0ebe6923538f799a14943304868e3b199001bb83bb469f5aaf5bbdf275ccfb66ed9e1e55bb	2026-04-22 19:09:35.518+00	t	2026-04-15 19:09:35.636029+00
507	15	0f4b5234e8fb15336c0ea7e1997affb7ab4163d8336383874b154f133b155f9ece94681eaba43ad8	2026-04-23 01:37:35.783+00	t	2026-04-16 01:37:35.89867+00
510	5	16ec90f989f79a11bd223ff044ba5b413290a19e6bd10253171c0cc7ec56ce3a82ee511955f39813	2026-04-23 04:25:09.5+00	t	2026-04-16 04:25:09.619136+00
509	15	24675c758431a13d6f5c511872f0fbb9f5ce242ce55a9013167f36251f71abc40f9b7163dca7104a	2026-04-23 03:21:21.096+00	t	2026-04-16 03:21:21.218211+00
514	15	1a58b8a09ccc3007b8c70dbfd9c4e4f392ca9036905417bb6033f2f91da47a7f3fec9d3efc611373	2026-04-23 04:44:57.089+00	t	2026-04-16 04:44:57.21499+00
513	15	388d3868bc48bf972b79213c1323c29a4aa56d257ccb79c8c083078c2101007aac68debf53a23d1c	2026-04-23 04:35:39.946+00	t	2026-04-16 04:35:40.062965+00
518	15	a56702e3b70505cfdd29ee1d70694a716c59389e1b51e923a781f31314e6fefb543ad5450cd1a71b	2026-04-23 05:23:58.149+00	t	2026-04-16 05:23:58.261219+00
517	15	6a60cf6d7b8d55fd1084016b3a638d9b2189aad44e96c7e240de0240e18ec5b1bf6ae070fb2292d4	2026-04-23 05:15:49.698+00	t	2026-04-16 05:15:49.813358+00
521	15	f0b072f87c880ee0b423fd198fbc58b0820dedbc8ee2062eed714cd354de1453976639ee249c487e	2026-04-23 05:35:11.129+00	t	2026-04-16 05:35:11.240864+00
522	15	afc54c3532ea61116bcd6a1ca7d0ed91a9722945f2bfe376b5b569e8da390fcf58e5c4d3b5c3c77b	2026-04-23 05:39:15.969+00	t	2026-04-16 05:39:16.080698+00
512	15	38072a393cca64dde20e5b3166b52268902265c7d78a3357a45cbf6de0e105c4d37ee2e38e91be63	2026-04-23 04:31:09.89+00	t	2026-04-16 04:31:10.006251+00
524	15	fb40cee185220b3ff5cb8874110c80b662b426978877a341c554a15d0c447e1a6519a31c87858c17	2026-04-23 06:03:06.391+00	t	2026-04-16 06:03:06.516647+00
525	5	8791a4e04195f02b94549a9873b681e6bfc12a832b2271cbe6562b668035fa2373d1379c812fd03c	2026-04-23 06:05:26.993+00	t	2026-04-16 06:05:27.11043+00
515	15	d2be98e198a81f6aaadd0e754a5ed00af0ce0673186b2c3661ad8714dc45ae639e226564cc7299c6	2026-04-23 04:54:24.235+00	t	2026-04-16 04:54:24.353598+00
523	5	9ca805ca54a32d640a0a456fa8ebee26e5c764974cc9d6cefaa8ef9683817e60bd59a6dd90c43d7b	2026-04-23 05:39:59.673+00	t	2026-04-16 05:39:59.784892+00
516	16	93c676adc03d6fbe42231a19f45bb5fdf30576dce125c632f1993cfa0db4ae2fb60660c4fd0ee76b	2026-04-23 05:06:18.192+00	t	2026-04-16 05:06:18.304175+00
528	15	9eb69c4f0cb5d7762043b7a4a5684ded91649d433dfdbd17cf8cb174b770a8a17db60867321ab346	2026-04-23 06:19:15.632+00	t	2026-04-16 06:19:15.753374+00
511	15	253d42e2a8a98701c1077340ab15851d4d4479878aa8760f344a2b7cd16c5df119d4597e693547ed	2026-04-23 04:27:43.912+00	t	2026-04-16 04:27:44.033645+00
519	5	0456698cfc6445623c7e12a6e5a73cce3efc49fa87e64c7ec47cc719222d37b360a7131faf7d2dd0	2026-04-23 05:24:22.659+00	t	2026-04-16 05:24:22.771062+00
520	5	35342c6eec94477a17fbb17fde6b5f879a89a5790167b119f3653a0c6f9884b0d915cb3e960df10d	2026-04-23 05:24:58.966+00	t	2026-04-16 05:24:59.077968+00
526	15	ebdc11a8a119b2565b1cf4581731884a9917e451184b907a1e32090b7cf253eb7ec8994989e6e2c4	2026-04-23 06:07:52.99+00	t	2026-04-16 06:07:53.113331+00
527	15	2e3d4ff84f2aa3489d92cde71d0522dcaaa61c4bc5f13c7770a0227bcb46453e18e3bd8c7a1c6178	2026-04-23 06:09:43.496+00	t	2026-04-16 06:09:43.614426+00
533	5	9b64d2f7a53f0526a7f9d87ef84b5064c864d1095e6d6f25592222d777d1d47c3ade1ea2b375e070	2026-04-23 07:53:08.858+00	t	2026-04-16 07:53:08.980749+00
530	5	8ed8b72957c37c42b5b71c42bf8b87ab5dcb7f8157b75893a49cccb1332be78ddcb33707c78c1f5b	2026-04-23 06:41:02.477+00	t	2026-04-16 06:41:02.600688+00
537	5	5037b4ed12207ef2f881a8536024d069e310eea376b6f0fcfa4d55d47a0de9cb7711d5d61af665a2	2026-04-23 09:55:10.811+00	t	2026-04-16 09:55:10.706692+00
531	15	5abed9526b9aabfe004b1b31fc80ec678d7fec32aa2bc5d4e34ca3d905ebf5cefff2049d4b0a6a97	2026-04-23 07:03:44.042+00	t	2026-04-16 07:03:44.161394+00
539	5	009549073d5bbd3281e706e44486ca3773692dbcc1d4e543ead3a51f3954f396482aa2102b134536	2026-04-23 11:00:39.357+00	t	2026-04-16 11:00:39.745744+00
536	5	bd474376c9f8c375f7836b0ded5e0ed4184e906b41c4e728aa62e39c83fd860b0e7fe8530c95dbb6	2026-04-23 09:54:48.611+00	t	2026-04-16 09:54:48.728174+00
543	15	a026f0e3a489c9a761360d3a39e8481c7e90a313fbc6e91b692a9490d69f0e94b7fa3491b489402b	2026-04-23 12:56:28.745+00	f	2026-04-16 12:56:29.219479+00
542	5	1c59328f8310fb29b2ae9849763474403fa43fdeb78fbd6486d7e3e8d055bd55d27add81cf40f2cc	2026-04-23 12:53:59.097+00	t	2026-04-16 12:53:59.218542+00
540	15	6981a28bcca2425170a05dbfe50685d1ce74239dfc5605d76cdfe34faa86222708092352939c9282	2026-04-23 11:27:10.274+00	t	2026-04-16 11:27:10.394399+00
545	15	94d6299c931c7ad0ba33f86af2998c03107f3d3a55a496a678dd783f159e46ce065884c76cdf4c14	2026-04-23 13:35:48.672+00	t	2026-04-16 13:35:48.783514+00
544	5	7e420263f8782d54cebc5e7d799b74b0a573c76a7b8e7202531e83da4a8e0114d5fd2076a7af4302	2026-04-23 13:20:05.85+00	t	2026-04-16 13:20:05.962046+00
535	15	5bb5aa5b798c447e1b6dbad20c6f8645fdf94235c983b066d6a5cb7edc0d634a1ee5a2454ab761a3	2026-04-23 09:46:13.795+00	t	2026-04-16 09:46:13.913837+00
549	15	89c6921ed80d038895fc963d9e6d8fe28a77e4940b5131ba0de2701bda838c1a3dad98974111a57c	2026-04-23 13:52:47.831+00	f	2026-04-16 13:52:48.310084+00
532	5	c71e5a869b0574efa0827a964dd1452daed872f884484344d83b2753c9474d008cfd574ff8770f72	2026-04-23 07:06:00.024+00	t	2026-04-16 07:06:00.145536+00
550	5	f5f798e987dbb327f904ee8dfeff653a4efce898eecbb5d99f01fe28e2deb4eb4597a50b452cc494	2026-04-23 14:20:12.518+00	f	2026-04-16 14:20:12.633434+00
546	15	fb1d98a1935ece2302bb180f2de912ca118364d57934a36be3b7d4bc8f6641439c48edaa3eb525d0	2026-04-23 13:38:55.984+00	t	2026-04-16 13:38:56.095741+00
529	16	28aad0e60e41bc34f8a69920186272a4c9c72ac9ed1c6a46ffcc95ceb2fcbf2beee995f8b3bd6d15	2026-04-23 06:23:46.402+00	t	2026-04-16 06:23:46.525061+00
548	15	459b61ebb9d56ca114b5c6c4d306b143227c65ea15b19a5b78d0dc711f71f346a37555cb9a53f5d9	2026-04-23 13:45:01.562+00	t	2026-04-16 13:45:01.673757+00
551	15	c414a17b0566e0f5ebaf29c7cf8dfad3a3065720bbacfd4e8b9188fb647f1346e61708d4db05a117	2026-04-23 14:39:57.441+00	t	2026-04-16 14:39:57.552805+00
554	15	50937f3c66f12ea5a7fcad4211734f8e7a7a437b97a14111d86f60a17c5ffc5a6ba98c0b818c5036	2026-04-23 14:49:53.963+00	t	2026-04-16 14:49:54.074916+00
555	15	1d19f98af9ce999272a6417f2e91cc2b603314c82eb7f527742c34dfe9a447b692705064e7f7a54e	2026-04-24 02:26:44.198+00	t	2026-04-17 02:26:44.309455+00
556	15	2e94bdb01298540132d593896ee96a2ff3a3976b8c2275f17e0655494c0429ba3e56e36b421c9530	2026-04-24 02:27:43.134+00	f	2026-04-17 02:27:43.24539+00
553	15	4918583127bee2d04e6b7511bc00756fb230000fa2be3626fcd9750886e7bfbbc7f61e608a33fd1c	2026-04-23 14:45:52.316+00	t	2026-04-16 14:45:52.428293+00
547	1	945690aee544e55172c2705f3872b035959da94e9931c93d44501305af1358ba8396318f9edcfe5a	2026-04-23 13:41:57.785+00	t	2026-04-16 13:41:57.901396+00
541	5	161937a6e69497e4b8191dd4765f2ff5244186f8864e52efe7517a016cfb30f07563a998cfc10f3e	2026-04-23 12:05:40.968+00	t	2026-04-16 12:05:41.424556+00
534	15	e22b0935368fd29a2db54a9650615683a78911319657332c6c4f894b77f3a278a61a9541a3fb74ba	2026-04-23 09:13:48.253+00	t	2026-04-16 09:13:48.370843+00
552	16	4d290809974f02752e31d216811bb68b15122f4da4403599689f76e3ecbbdbb595d30818a9f36563	2026-04-23 14:42:54.484+00	t	2026-04-16 14:42:54.596055+00
558	15	7ea22d671fe88387622dfc51b9a609b79719d55288c976115cb444858066e8e38db40abf56be5f37	2026-04-24 02:36:43.756+00	t	2026-04-17 02:36:43.868169+00
557	15	25ee4b4f80e267edd3106393e0a716bd430395eef64e2f8daba0dadac08cab2f4e4311ef786e0d44	2026-04-24 02:29:26.677+00	t	2026-04-17 02:29:26.788152+00
563	15	721aad8cd1dcea4bb1fb3e43c333b63dd19f15da66a0720bf09d299cd5cd36e0e114f8a150a2fe46	2026-04-24 04:58:11.222+00	f	2026-04-17 04:58:11.33772+00
560	15	88a0eef3474f8143010c0c4384b014e9586b11ce5cad838f5a995f9caab3f4cfd92842606b28c76a	2026-04-24 04:14:50.659+00	t	2026-04-17 04:14:50.771845+00
562	5	6115d357e239aca4320dcf6e54cf526eaa918dfe9d6125b9a20474c3ac1edcaa18058f2d0aac098c	2026-04-24 04:48:22.16+00	t	2026-04-17 04:48:22.887882+00
559	15	b941fd2b6306a38e717755e98d6245d22e12c20b8fef2556df962a39180c3ceda0dd53e940913b7c	2026-04-24 04:09:37.838+00	t	2026-04-17 04:09:37.949833+00
538	5	1bb57767b427c713a8ef783063aa64e3e0f165e280ff7ffaf848a2e17d4b94334da7f387537358fc	2026-04-23 10:15:14.278+00	t	2026-04-16 10:15:14.397018+00
561	1	f312b0400687a37fac43e2597331daaad64043baef4c74f21ef09e99f9001e1f0cca045a788bc48b	2026-04-24 04:46:57.575+00	t	2026-04-17 04:46:57.68664+00
565	5	fe92b902adcfeabe5adb0a14f622d1a5cb09c4ea48af9fb59c8c382d2c73c467f20cbc6a6c88e175	2026-04-24 06:18:05.883+00	t	2026-04-17 06:18:06.676546+00
569	1	146958b476e621e0c25620836fd9bbaf3561bfbb718fdd82c530bc104f35bfc94073f6a3a1efd79e	2026-04-24 06:48:25.931+00	t	2026-04-17 06:48:26.042889+00
568	5	9c3dd1e6c5076f3fece879d07171fa8f65f59568c0220ce0628d940f470e71b8c77837d6b2d98ba6	2026-04-24 06:39:18.553+00	t	2026-04-17 06:39:18.664917+00
570	1	65486950ebe69172f3e4b0c8d22f0980927c44bebfa11544a5169d8dfd7ff0c9318721fc84a9dbd7	2026-04-24 06:55:26.162+00	t	2026-04-17 06:55:26.967424+00
573	5	f8f099391d348a6365e9def7f57142359f0ecbbd89b9e5c82d4ab1baa563381555e653d1801ced5d	2026-04-24 07:13:09.967+00	t	2026-04-17 07:13:10.822771+00
574	5	2814e332af972b2f4e1da9f34c3cd256472de80a812be70297544ec2e0397366f6ce63c68ff0d4a0	2026-04-24 07:18:23.474+00	f	2026-04-17 07:18:24.309958+00
567	15	6de78bf958f503ce735ff93965db11debf64419c8ddce6bf82db3416e3a71dbdb58b66e38fee06be	2026-04-24 06:19:47.846+00	t	2026-04-17 06:19:47.95849+00
571	5	b52d306795147a73e401014520df3f4b7163c69d20d466773f83f2a8f222bfe8b78829904d4168bd	2026-04-24 07:00:56.903+00	t	2026-04-17 07:00:57.017957+00
566	5	e2a385188d47853f7677a24b62e28a3c2dc537a8300f7bb7cea9b7ba8954ff826195489e7e1dd155	2026-04-24 06:19:33.183+00	t	2026-04-17 06:19:33.294655+00
572	15	91f533dacee7910fb0e7255209eff6ceeea90abdd148e11804bcecc5748661e0c460a9102b560983	2026-04-24 07:06:25.571+00	t	2026-04-17 07:06:25.682556+00
578	5	0fdcbdfc9b98ddccc3aea27692ae488ef6e1da62c7bf826e586d12854ce3c24c5f2db3edc9d60a68	2026-04-24 07:28:05.459+00	t	2026-04-17 07:28:05.570278+00
577	1	e7ae77b3f52e403a993ad4b16b324aa388e24848de798d8148b33a28fbfaa39070bb635a4f5ad274	2026-04-24 07:26:36.887+00	t	2026-04-17 07:26:37.737601+00
579	5	c078926e395cceaf251ccf4f63d64f25a7a1e01f9aa848318ba369d28b676b2908baa0911d48c338	2026-04-24 07:33:46.011+00	f	2026-04-17 07:33:46.121892+00
580	5	154e1490285f550db67936435d2ced82c409909cf9c664285968b5abdd15dee35dc70a0daa04b452	2026-04-24 07:33:53.266+00	t	2026-04-17 07:33:54.103963+00
582	5	5301c54dcf15df98a15ce119e3cb88ae3e3707f67533dc465e2b1eb437741996123fbc92d7f38727	2026-04-24 07:37:26.817+00	t	2026-04-17 07:37:27.673279+00
583	5	2e3ef136c8dc2a3bbecef3d2f6f3cf4bc0c6ae00d29073c258a5df3f8c7e17e37fc40430c0f531e5	2026-04-24 07:39:30.209+00	t	2026-04-17 07:39:31.060443+00
584	5	146f290625a890aebfca02e65621de39c1ca6ff29e47443cc9910a64676e409ace170ba4fa15ff60	2026-04-24 07:40:10.871+00	t	2026-04-17 07:40:11.696374+00
585	5	5def169608826b83beca886683ed6aead071089e918067d98df589d2d2a8eeab81b0a641190e02d5	2026-04-24 07:42:02.038+00	t	2026-04-17 07:42:02.881498+00
586	15	d7e62a0d4a3cd56e99df0c04a0754f401b76183a28418547f62c44c240c9abbbf7db137b727e60ff	2026-04-24 07:43:02.531+00	t	2026-04-17 07:43:02.642505+00
589	15	d2d0a5161ca3edb7f38e40638b448a245caf1a60f0c67bf7ff183db9d09a5db79a131eeb307a53bd	2026-04-24 08:01:08.582+00	f	2026-04-17 08:01:09.434143+00
576	5	0b6e66cce425d533ee9ab5e241218f89e6149b28e6507e02724f78ad93ab94c11052b6157a756ca9	2026-04-24 07:24:27.935+00	t	2026-04-17 07:24:28.051303+00
591	5	ad0ab59805bbba121636b7bd25175fe7c4ebec3949a8d639d2165d238cd0bc22735a16e0fbb6f756	2026-04-24 09:08:45.009+00	f	2026-04-17 09:08:45.120923+00
587	5	667f5441c2255cab07894261b018f5dcfb9e635730e3c052cc9d84b37fee1d786ac8ce0589398230	2026-04-24 07:44:22.685+00	t	2026-04-17 07:44:22.796071+00
590	15	68a5b6cbbfdf534e4fde7314f1b30a83e36cf8161aa9adf83363d08b707e735a4fac67518671c85c	2026-04-24 08:03:36.454+00	t	2026-04-17 08:03:36.565511+00
594	15	9b19072016a020b554ef54892e925d5015c8531ab216b7a11e4640643f9b31c8b0dc4b98b6106721	2026-04-24 09:56:16.067+00	f	2026-04-17 09:56:16.179324+00
588	15	4e9517851bd39e8de9eba2e50d42be2ef17edb0708e757253810afa70837e6aa1f3feccb47173edf	2026-04-24 07:48:42.131+00	t	2026-04-17 07:48:42.247327+00
596	15	d345d6e518210ed099792b1e45d00e8a6bf447afe04f1eba4277d749b1ffd9cadc595719be62c8f6	2026-04-24 10:11:30.764+00	f	2026-04-17 10:11:30.875655+00
597	15	791d1fad98c2b942ff6431a67a66599a05d7e00caf3d84012d6c512a8693bf300dd400ff939b8c62	2026-04-24 10:11:58.891+00	t	2026-04-17 10:11:59.001777+00
592	5	f7ed48feead48a85d651c291c0cfb9d4e11eca7afd8f076e197ef1991b4cd07cd326edc25eb8c651	2026-04-24 09:11:50.664+00	t	2026-04-17 09:11:50.779101+00
599	5	c86786b3dd535ca715e7c365c9255d09a143b9655a883f05ef6a2cadf5ef19a1e65aaeaabeff6dd5	2026-04-24 10:17:26.754+00	f	2026-04-17 10:17:26.865052+00
593	5	bf8d0dcd7c8a9ac33f2f266d0dba28601259251d71cbc63313a57fad4b25e6818a95b713225fca5c	2026-04-24 09:54:15.327+00	t	2026-04-17 09:54:15.438816+00
602	15	ecc4e075657e3b0dda5fa69d49109d4416a886b4411de5c19ba32b538c27ef02ec9461e785156680	2026-04-24 10:26:18.952+00	f	2026-04-17 10:26:19.062724+00
603	5	9e98c8c47ce9f9640e46743639770b65587261bc1af0b3bd3768d5840f70c707798bb65471921de9	2026-04-24 10:26:39.78+00	f	2026-04-17 10:26:39.897718+00
601	15	1595c3aeaf2986fa0e05fda5f190d05e7061eb064cb4ee9e1acd86732e30593cbe9e2c8f6099891e	2026-04-24 10:23:25.015+00	t	2026-04-17 10:23:25.126547+00
575	15	c7d473d78f1889280762e17a6875ad7e4c43fe0c34f320a896b53cd65fa5bfdce2a52742d1ce8efa	2026-04-24 07:23:55.693+00	t	2026-04-17 07:23:55.804827+00
595	15	6dad364452f6fae2d160049088ff3455cd4e69a080f3db6c78dfff3c6665c0943ab3d1cc7e9167b2	2026-04-24 10:02:08.582+00	t	2026-04-17 10:02:08.99424+00
606	15	0d43a677664049d029d7ee586239a4c0d5722e20d3b33411b72636df440318d3aa7f3183d7fa7ca4	2026-04-24 11:12:31.57+00	f	2026-04-17 11:12:31.990796+00
598	5	fe46e7de819bfac0badfbc04baaad6e2d7ae28fd15402c0cf6206cd1badb6f9f65e2af04086fc0eb	2026-04-24 10:15:57.899+00	t	2026-04-17 10:15:58.011272+00
604	5	d973bc15cf0e5c531ad6e13a1bfe495460b054e7437e95277c2a02e004b426d33757afd093e491d1	2026-04-24 10:31:21.412+00	t	2026-04-17 10:31:21.523578+00
607	5	f33363b2f057612799287a65afd18155ba636bdc5b7171f24397bf84bddcea7bae951726c9126f28	2026-04-24 11:17:32.454+00	t	2026-04-17 11:17:32.906514+00
608	5	732e76d91aeffa7ee855eb4319e8a86973e45d5c134759e3206e9e04e67e3706c8578422f296c1ce	2026-04-24 11:42:13.398+00	t	2026-04-17 11:42:13.520741+00
564	15	80d2202af0b13860d37be509756aa69a169d00d59e95b1712f97bcee7a613cfb83cfd022b2db54ef	2026-04-24 05:26:52.891+00	t	2026-04-17 05:26:53.003+00
605	15	468a035ce5afd5c54a9f74b348d7ea711a76d5316fbbc86e5f3b99a4a5aee9b9aedc6c954604ce5b	2026-04-24 10:58:33.354+00	t	2026-04-17 10:58:33.470947+00
581	5	76ebc453de1fb80c3aebd4b62db50ca099ab9bd41606d0ce89461d02c8d8e106846890ce3e239349	2026-04-24 07:34:13.078+00	t	2026-04-17 07:34:13.189352+00
600	5	c537b792afb75528aee97101f95af62a8974fb91c3b1cb7d1cfc848c4f45129cd56d11787a1e162c	2026-04-24 10:20:51.455+00	t	2026-04-17 10:20:51.570956+00
609	5	d8e6c119682ff1db23b7f702c9298c93f0ea15be059b8b82ad1eff55b3ff7ae18ccd4c52174e8db8	2026-04-24 11:44:26.194+00	t	2026-04-17 11:44:26.308887+00
613	5	139a73aad1f89a46412670edce4d0ddf72b4aa079e9a1c91807ab8cb2d7346ad45f1792e126a4b5a	2026-04-24 13:33:27.202+00	f	2026-04-17 13:33:27.322198+00
612	15	ec0b9deb0cf077640f25a766228df9e60a5e6511d134553409381b1a51afdf5633b36a0b8981d5c4	2026-04-24 12:49:51.91+00	t	2026-04-17 12:49:52.024612+00
615	15	46b9f0f28f9f2e31bc8b3f80a64f3f4332af58bdebe46a47893f1688de782821ca4caec883de8618	2026-04-24 14:11:15.99+00	t	2026-04-17 14:11:16.101373+00
614	15	d28c87040b9d19c457a93a4e3b4f133c304c7bd57cce7ad6fe58fe88e8afdb13b834e4c2f6fc7ebc	2026-04-24 13:43:04.674+00	t	2026-04-17 13:43:04.785952+00
617	15	a1d923684bb4c3be0a6916148893790d261884239f40dfc910ac461f6e4e7956f50213a4341b8239	2026-04-25 02:12:19.261+00	t	2026-04-18 02:12:19.372316+00
611	5	cd20516a2df00ab3d09ff70f5842e271b31c2957836739d1ffde3a886ddeb683d3eaa67f18e1ddd1	2026-04-24 12:44:43.8+00	t	2026-04-17 12:44:43.912665+00
610	5	cb38691431f38b38952cc00d8e4b8448b7b9e0c6cda7d320a66069cbc74dd4d2a5a14e72f1e58983	2026-04-24 12:17:42.946+00	t	2026-04-17 12:17:43.429296+00
620	5	da1dba7d94d536b0e04226f5f0aeda7070d313f8e5e4bd75f35c55cb53b129f72375d5023fcd2580	2026-04-25 03:36:37.502+00	t	2026-04-18 03:36:37.613573+00
623	5	f06ec754e3f95147f8657f1398ed76c5c442918a51e5f3bed99bc23039f53655252ab1d6aa294682	2026-04-25 04:37:29.925+00	f	2026-04-18 04:37:30.037761+00
624	5	4a7f09a03ae045f220803a170615a1123d9f880ec4fcee544b664ef6e5d40def7bf4eb8bb67c44f2	2026-04-25 04:37:36.914+00	t	2026-04-18 04:37:37.035923+00
621	5	03a52c6118edcafb9d68ffed8cd6710c7855ab2f5147c4955f546aa5a8f84ba9b3a2f3ccef1c2b65	2026-04-25 03:39:27.694+00	t	2026-04-18 03:39:28.437945+00
626	5	c6800864bc14d80766cfea507e038b1bbff012d9702047b88ed8d589c7625fcddcd4fed17f312602	2026-04-25 04:45:40.451+00	f	2026-04-18 04:45:41.182509+00
618	5	81c897525f71d825be8bcd918f6069bcec020655acab1f08d406cfd82195488d54df5f23ca8c668a	2026-04-25 02:13:33.189+00	t	2026-04-18 02:13:33.300847+00
619	5	257da4699de54ed1cbe19c2035a33d3d0b371dd5689c6cfaa78d2e362d046f68e62f53c085a391ef	2026-04-25 02:21:24.434+00	t	2026-04-18 02:21:24.546033+00
631	5	71cc8261e4ad26d430a394d0d090e9cc57fbccda55499a0f6b2ec2275660768990baedf54733ce21	2026-04-25 05:13:23.624+00	t	2026-04-18 05:13:23.740549+00
632	15	50649d5755e19462322e39ba8ec05e2bb162cb4ad97f6fdcea11c3d672cba461a2ee641ee8c62fde	2026-04-25 05:13:51.612+00	f	2026-04-18 05:13:51.72681+00
633	5	018a9eb61042de72d1341a69fb9f71dd169a076f26384b098838229ade779be2516e42fb92ea4ec0	2026-04-25 06:10:05.763+00	f	2026-04-18 06:10:05.878326+00
627	5	80016ac919fcf416dbbcb78055aee503660d70e8fda876a1800fc01da904d03a0faa7c37bb85b2a9	2026-04-25 04:51:50.33+00	t	2026-04-18 04:51:50.442311+00
630	5	3474c68c66a3bcb23ec2bf60425bc1291a866bc9dcd44fcef0aed997bcbdfa0aabdb568e97814027	2026-04-25 05:10:45.821+00	t	2026-04-18 05:10:46.569533+00
636	5	52f648f9ae1ce8ef5855b0b184879ade36a204f4154e5a3be2cbcf7f1ac24913acfb3ecb5762feea	2026-04-25 06:47:22.815+00	t	2026-04-18 06:47:22.931897+00
637	15	6352c534f42b84a5f444d7c4c262feb149ea229503f625904fe929ae5f027f235f3e2eba247d6368	2026-04-25 06:53:27.961+00	t	2026-04-18 06:53:28.077734+00
638	5	3f5be448da5429c714124a94359c721e87c2000246632b4f9ca17dbb1c4fbe63a1160e07ea06978f	2026-04-25 06:57:23.764+00	t	2026-04-18 06:57:23.880718+00
639	15	09ea0cab3fa7bd80c4fca9942917154b4f651ddf510e6acba2ad0b4a3b123af5315a475291f9d6d5	2026-04-25 06:57:35.454+00	t	2026-04-18 06:57:35.569848+00
640	15	92d8a7cd15dde4c634c61b15e4b2e80b93a1dc101ce541be12bfe6830ff231f4d978a7baebfa3d83	2026-04-25 06:57:43.627+00	f	2026-04-18 06:57:43.743136+00
628	16	c4cb2553167404c58013c5760c228992548840bad4aab4f7c13f7fc34d4fb451e78ada8603ca5421	2026-04-25 05:08:23.257+00	t	2026-04-18 05:08:23.368885+00
635	5	37859834b044e095064856c5bf8132615c627675ea4228627a8b02f091c87ed0df11d976ceb61d01	2026-04-25 06:24:35.159+00	t	2026-04-18 06:24:36.461896+00
643	5	8ac52ae8d23cde428e67b3d5ba054ebac68c60ca13cb866df4ae096c26cfb48bb65a4901f4872724	2026-04-25 08:00:29.977+00	f	2026-04-18 08:00:31.63228+00
625	5	2d82cbb0ec8beb82974752fe0352e33fc71881f70acde078146f70db0f598e3b31b89a9ed48e9d00	2026-04-25 04:43:53.686+00	t	2026-04-18 04:43:53.802029+00
644	5	4de3a91ec07ee96c7223939f0075fe01214a2ac210be76b039a96df7867ae61c6fa8c6f018e80c7e	2026-04-25 08:01:35.402+00	f	2026-04-18 08:01:35.517135+00
634	5	672cc113b3acc17569a3d829b3b7177b82588449e763fa770d2de812f9666d607e1d2ae7a3c11b00	2026-04-25 06:12:11.844+00	t	2026-04-18 06:12:11.959877+00
645	5	9fe2212da0135e746814b1a5dec453dd8ebcb3d5427d9eb315c4ab278ceb94e1c28fdd18be4ca838	2026-04-25 08:15:46.213+00	f	2026-04-18 08:15:46.329548+00
629	5	ef07db95b0c132d0feebbe2ffe87f0141219c0f3cb483137ad622b3550cb131aed3ea22331c73836	2026-04-25 05:08:26.313+00	t	2026-04-18 05:08:26.425472+00
642	5	2c3692f0d87f66048a5db820174909fae8620b8584892bb7151b7ea4050e5b2bb7a1c827009b1822	2026-04-25 07:41:16.836+00	t	2026-04-18 07:41:16.94968+00
647	5	c0dcca700d9722f7f1510ada66999c41c76385766b12ad7b4e14899f22e41ea5f445242d96c4931f	2026-04-25 08:23:41.862+00	t	2026-04-18 08:23:41.977558+00
648	5	01052f6b3f782d221ab54534b3d41f975d8a9df629bab1027109001b5ce441fac20dd3d419b724f7	2026-04-25 08:46:21.288+00	t	2026-04-18 08:46:21.406513+00
651	5	3cdb0c8c77dbfd59aa9ee6270513c8c9dc64a649df7aebc74dced4c58b2518f09f23f75fdd71fa53	2026-04-25 10:13:59.891+00	t	2026-04-18 10:14:00.006608+00
649	15	179ef78c1c6faeac08e4242719af02542e44ef983240b78f3e80df909095cc7e3eb3e80f8636ddf8	2026-04-25 09:28:21.73+00	t	2026-04-18 09:28:21.856512+00
653	15	cdbe2ca3efac7399e13eb2f1c5024b0e552607ce122161cc975a77aa4bab6b2fe9421171676e08b5	2026-04-25 10:53:31.299+00	f	2026-04-18 10:53:31.416817+00
654	15	e77a8884c54fe43b3c04798c514a6057c02b2e78b8f0753c6efe2af889b944ff5017916dcf688e39	2026-04-25 10:53:31.399+00	f	2026-04-18 10:53:31.522261+00
650	5	b177edd6a1a9453b58e97bf363e2fe37e29d1303f61803fff686fecc3578b838247dfc94d580708b	2026-04-25 09:38:56.044+00	t	2026-04-18 09:38:56.158754+00
656	5	be1d28b294303e6a89a198b9264849bc1590216c098989489262fd5d3ab4c831a14e615596133039	2026-04-25 10:57:48.058+00	f	2026-04-18 10:57:48.174159+00
655	5	c242871a2279309f6a39d0757c9da498afe5344a71efefe4d44c3b4ee13b6c8bfdb1efc233b89c82	2026-04-25 10:57:19.62+00	t	2026-04-18 10:57:19.736654+00
646	5	0236ef1de0e0cde6f06f43c82adcdb53c474e14b4a91fa16e6c09ca75b8f9873db8785b68a3e3b37	2026-04-25 08:23:16.336+00	t	2026-04-18 08:23:16.451001+00
658	5	485c85399194c683ca95eb0152b335e490c153596cc6d8e30110f11082584838d1bb75cd18769b9e	2026-04-25 12:03:35.59+00	t	2026-04-18 12:03:35.706087+00
659	15	d3d0cd5d07d83e70f1f712bfa393194735829ad909ae5b1de3970a4a3aeb591d62f85cb469548bd3	2026-04-25 12:04:08.277+00	f	2026-04-18 12:04:08.39185+00
641	16	319c229fbd9624d842cb035969901d63753dfde6d196a5029d6575cba841ab48ad27262a81ec0005	2026-04-25 07:20:03.163+00	t	2026-04-18 07:20:03.27825+00
660	16	3f691fe66cde6662e258b36340754c65efb44fa46249edc3a4258272e86af79eb950abf160991b08	2026-04-25 14:54:34.34+00	f	2026-04-18 14:54:34.455892+00
661	5	397a31a21897b27e4a1dccd40da959b938a34414fdfc673e8d0e5ed67a112a18571a2c9a340460c6	2026-04-25 17:38:19.671+00	f	2026-04-18 17:38:19.786528+00
657	5	a20698372f421d47d8e723ac4ca189b5493113992caf775348927b634bc303929c36a0c5a3c58d76	2026-04-25 12:03:18.673+00	t	2026-04-18 12:03:18.788512+00
622	5	2a29253eea118b0fed48c5a6663e97be251086ac0918ad44e5916920e651148aa9614b329bd27700	2026-04-25 04:32:54.325+00	t	2026-04-18 04:32:54.436823+00
662	5	b09e7aa347f23e4e545cefaa1092ad14724363d29459c19b63e77f770b102401e0562c0549436beb	2026-04-26 02:30:00.198+00	f	2026-04-19 02:30:00.309968+00
652	5	8020ae830c25b0599defb194d43b117b1ddabe8cf60933e5724a6126ab80123549ef4e83bc0991bd	2026-04-25 10:17:27.368+00	t	2026-04-18 10:17:27.486962+00
663	5	118e3a7c1ede5f227b04b9ce31e0e430dcafcc06a3269e5b6099831e6cc4cda2e0a44af7529785c8	2026-04-26 06:25:27.272+00	t	2026-04-19 06:25:27.392355+00
664	5	63ef8302fa777c7506dc9112f6a8e1eeb03a1599038487290ab47c494365c6167783a3eb71e709f9	2026-04-26 08:03:15.481+00	f	2026-04-19 08:03:15.598348+00
665	5	36260200950af798c3fc6a91093e901005129d1bc1455a95c34df311141d30ff13a1231dfb570377	2026-04-26 08:30:06.734+00	f	2026-04-19 08:30:06.845978+00
676	15	c8617bd02586ebbab5ab8ab416e119351deb653e72e9e8cbd3e5464449ce650b1902b058a8790930	2026-04-28 06:01:29.031+00	t	2026-04-21 06:01:29.034028+00
681	5	cbef54510d7455c940e35ef2328dee86a59bf05fe8ae78ac17177a11a2d1e48b6f530466e2d662fb	2026-04-29 05:34:17.321+00	f	2026-04-22 05:34:17.323653+00
671	15	90a15b5832c1adfb4b9d10dc4f9020f6c67c3f93749cb1726273f61a40f021ce34225edef54a785a	2026-04-27 14:04:47.116+00	t	2026-04-20 14:04:47.118143+00
686	15	571bc02df46b3c1cc087aabfe9f9e40115ef07015a26044eb1e04973b19f7d577d61ce07503d747b	2026-05-01 20:29:47.73+00	t	2026-04-24 20:29:47.732526+00
666	15	a41fb84ab3e1df0fb08c0ba5c8c56642b3733f8971e7420b60b6e056b47b2e71dba53edfa07a7a08	2026-04-26 17:31:35.937+00	t	2026-04-19 17:31:35.939205+00
691	5	6b2829ab03a17c98ec70af1791befd39c6ddcabe913014a05b35ccf2ee037bb70bdaf6847576ab97	2026-05-09 04:59:45.816+00	t	2026-05-02 04:59:45.818694+00
694	5	f0026a1bb82415283cba04459bd9a1fb96908b31e8fafec865ed9b9955c4fdaf3b8f4c69452b9129	2026-05-12 05:13:21.092+00	t	2026-05-05 05:13:21.094743+00
705	15	9542c9c56d10060d29cc87de41be7a025d635251bfcb9585acb232a6a018100ecb587b794eaa3da9	2026-05-16 09:22:13.059+00	f	2026-05-09 09:22:13.060284+00
700	5	230e382d1bd54bcc1261e986ffac2d3c094fc9c1697d5f71c093f6d439bc770cfff07f8b346cef2e	2026-05-12 09:38:29.819+00	t	2026-05-05 09:38:29.820474+00
710	15	97d928715bee3f89a40dba3e4322396a6513f45f06e8607579ff935566a6f0bf170c2c4b11469197	2026-05-21 06:12:10.741+00	t	2026-05-14 06:12:10.743195+00
715	5	ddc8589e491b039d1b078789dcb779f2772b2b5dfcce070bed7be86bf294e9af3a5932779202eed5	2026-05-22 07:13:13.048+00	f	2026-05-15 07:13:13.050621+00
667	5	4e32df89fbfa46aa7dca96be5a367e76ea97939fe7b481c9f059b2181e9cf33c7c546a6988e49208	2026-04-26 17:33:26.576+00	t	2026-04-19 17:33:26.579068+00
672	15	64a600e8429c7ea92432cea53765907a34bff1b2b3e463fe7c111083083b3c9587670ca78a6a6476	2026-04-28 04:25:09.467+00	t	2026-04-21 04:25:09.469946+00
677	15	331501502f49b4766218577ba112360abda89b2b7b9dc295a28b735ed3a724abd7db82956106d937	2026-04-28 06:04:26.95+00	t	2026-04-21 06:04:26.963697+00
682	5	fbb8a9562b2a68b0ea98036541caa094263812fc61e6411df9807a6d5aa142eaa65eed7863fbda62	2026-04-29 06:20:55.078+00	f	2026-04-22 06:20:55.079724+00
687	15	bb399eb807937441877980b89c5674abc99cae51a4ccf09da6f1019f7892ab18c20f612564f90ca3	2026-05-02 13:10:41.652+00	f	2026-04-25 13:10:41.655658+00
692	5	bbe0f68dacb62f01962cac8674beff81e58eb1fc2f4f6b7fdc423b0858dba22e3d366d8859e250a6	2026-05-09 07:47:09.164+00	t	2026-05-02 07:47:09.16599+00
695	5	0ea7dddf5ce8ef29429334d25ce58040bc1bb75f6c03f3a56241edf6b9abf571512c0ffc4c1eae00	2026-05-12 05:19:10.742+00	f	2026-05-05 05:19:10.744682+00
701	15	3e8f9785c7ccb1e63d34f0e44d9c3baf8ad8adf3a1c2bceea42a0be8be462894a4be629bed925173	2026-05-13 16:25:20.055+00	t	2026-05-06 16:25:20.057698+00
706	15	37d96451a4dc4624f8cae5bb2d731e1d3639c07f7c27614bbafa99d6e6986419a9dc85f07425134f	2026-05-16 09:22:13.77+00	t	2026-05-09 09:22:13.772407+00
711	15	70019f92fe132cb5f5a5c7efb0b868a22a55dba3e658173a593745d20e5fd8513f1862d5cd411c7c	2026-05-21 06:22:37.392+00	f	2026-05-14 06:22:37.392709+00
716	5	298fb56df58e3f331517903d6ee6dc206d70ca3fb085052d4ad2cf0d213b9a749b7dff2faaecdd47	2026-05-22 11:46:45.051+00	f	2026-05-15 11:46:45.053356+00
668	15	6b49135af11a4aafe18bd0276d6a069c4163c1992c3568045a073c831e29d372c7be5421fe51ff9d	2026-04-26 17:34:19.446+00	f	2026-04-19 17:34:19.448769+00
673	5	80bcbe94780b8260b00f30e3ede0231299bed5410d2f6c8f2b88c6f976cfd1820c1a24d38f8af02c	2026-04-28 04:33:15.192+00	t	2026-04-21 04:33:15.194313+00
678	5	9727c3c6fe28d7b8dccd481cf410f5654def2083223742ce5c7e55801279f356b8f49188f6252541	2026-04-28 06:04:44.685+00	t	2026-04-21 06:04:44.689592+00
683	15	970f0a6772ef37ee7d6b96ffab3abe17d00ef80870b63e6513051690bcee8aac9455e611fcc00b13	2026-04-29 14:43:35.995+00	t	2026-04-22 14:43:35.997639+00
688	15	376fb6024cb63796fdc39da2894955ff4fbb1bc855d7dc04209c41287bff4eca0477551a31ff5950	2026-05-03 11:06:50.593+00	t	2026-04-26 11:06:50.595194+00
693	5	21a9c21b5c8d7452e4aac20e02724b7009cdd1594ea9eb638dfcf85901bf7b5a52b1caa5907f09f8	2026-05-09 10:03:15.252+00	t	2026-05-02 10:03:15.253717+00
696	5	f8954f395b91635c51338e90f5f90b237858a2a53a6538dcbfe4ba597b4e3135cd24d46e0e1b3504	2026-05-12 05:19:18.101+00	f	2026-05-05 05:19:18.10371+00
702	15	4c7a67894d3e8ca0ed32b7957029f2b4b76913f2d5636c91f5841d0f49fed5b8260dc8f24fd0d07b	2026-05-14 04:13:32.49+00	f	2026-05-07 04:13:32.491681+00
707	15	0d39014faffa01158a08393077f75cb14a8f66807c4267f42db1e817ef7285226e2102d319f9dca5	2026-05-17 12:39:01.854+00	f	2026-05-10 12:39:01.856547+00
712	15	8b57e5b7eeb16ceea912d001cce09c6ce7c8f33e2e44ae10456ee88e6c919cc747630609ebeae54d	2026-05-21 06:22:42.554+00	t	2026-05-14 06:22:42.555231+00
717	5	9664fdad677878c89a31d051f01ad4692b3201ac41bf11fcfcf71330b5becfb71e418b821dfd4bea	2026-05-22 11:55:01.644+00	f	2026-05-15 11:55:01.646815+00
616	15	ee8cdbdf01960e6bc24fe7a9571af9aee6ad68198649c8ac9f3697fd5ccbb7e44a243dac89426e56	2026-04-24 14:11:18.802+00	t	2026-04-17 14:11:18.913463+00
669	15	6798429ddecdae5c950e101fa1d9a32afd1f8c855ba49c6c4e4ad9edeb6f78b29e4bfdf15bfbc569	2026-04-26 17:48:22.256+00	t	2026-04-19 17:48:22.258335+00
674	15	376aca74db87fbfbae47001865d9b40378aa0b1023c5481649b46bd27d1af755ab17be26eb527b43	2026-04-28 04:33:51.791+00	t	2026-04-21 04:33:51.792894+00
679	5	800a52d926fd9da17c9c2fd45037d417ee5360afcd0f5ae93ff28cfa8e93e854ad7d6755a15c225f	2026-04-28 06:23:21.898+00	t	2026-04-21 06:23:21.900406+00
684	15	fe2eb6810f3842637261ac6a5a7d2094a72185f7e171cc909f2a08ab856aed8cdb19435374d8ae1c	2026-05-01 06:07:10.198+00	t	2026-04-24 06:07:10.199815+00
689	15	b2b86466ce7e60f99035119bf65874a103633e4498470c286222df0b07e5d93ae70d26980cbbdf64	2026-05-03 12:34:05.862+00	f	2026-04-26 12:34:05.865323+00
697	15	d5181da9227bd37b4fad8c85d96322d43da86558169b6ed97494758d0f1eed0f7b8032020bf331cc	2026-05-12 05:41:09.918+00	t	2026-05-05 05:41:09.920578+00
703	15	00f0ad46f8d29bd90a718202b091ef02422a8eb3076fe225c900b8fffc2f0f9a6790e68ee69a8597	2026-05-14 14:11:00.119+00	t	2026-05-07 14:11:00.121112+00
708	15	d7701ea25f91f7496d13117ffe01f1dd21a197977deeca9674e74296c3fc528c4243f6be7e49c641	2026-05-18 03:48:53.411+00	t	2026-05-11 03:48:53.413729+00
713	15	1a9cc3e18fbddfa78da5ac8fb903d59530a26706cfa416aefa9739f2f90b2ba27a5a9111414827e1	2026-05-21 06:23:04.255+00	t	2026-05-14 06:23:04.255949+00
718	5	fc4e945e2afa1b8ec90a2ebd441c34e2e8d3cbac3a1be1d91e4c1f1e12c1cb8e9bc782903109ddbe	2026-05-23 03:47:12.47+00	f	2026-05-16 03:47:12.472231+00
670	15	5a2590eb5b0f39a7489fd188294302cd39b266b7a6a2d321ba2d76a33eaab1f87580ebbb13df8c50	2026-04-26 22:23:27.348+00	t	2026-04-19 22:23:27.350361+00
675	15	ab01761d19fbad81edf08b916332707f1ff768f3eee25df268e357010c937a56bb327a61ae8265b2	2026-04-28 05:26:46.07+00	t	2026-04-21 05:26:46.072188+00
680	5	14fa080d1e01ce21495233c88de6bfba8b2249545f81a82c0f7cd58fa0a88c80e284f0e252919e94	2026-04-28 11:14:23.92+00	t	2026-04-21 11:14:23.92233+00
685	15	8b86eb242bbe5d5b1b260b600d8575890d37d2de7518a1217311098128300e1e11f1686cac548e27	2026-05-01 13:58:50.221+00	t	2026-04-24 13:58:50.223228+00
698	15	c13e129b5768df7e6a975ad2de6ad3f867072bd9ce577c745ef3c85c001992fa83ef58963c89fc59	2026-05-12 07:29:09.532+00	f	2026-05-05 07:29:09.534235+00
699	15	ce733086f425eb863f7e5fca155d1be1425154560c1ed1519a9757c352bea112f8db078dc4839178	2026-05-12 07:29:10.998+00	f	2026-05-05 07:29:10.999688+00
690	15	528ebee753afeb7229df7bf8414d9f91395f4a180335ac0e3d5c6c0efa14bbf7ae98751352ce54d6	2026-05-08 21:00:39.127+00	t	2026-05-01 21:00:39.129364+00
704	15	ef68ad2dbb6acde3def40463932215ef1c6b163e9834c395feb7e7af2d8334b47c6d92ffcb1956d6	2026-05-16 07:38:03.086+00	t	2026-05-09 07:38:03.088717+00
709	5	e7acd2e417bb130374fee699cbb4dc6b4fced69477235892585b1aac36aca2ce7c9e2dc7ec2c8f1b	2026-05-18 08:30:03.292+00	t	2026-05-11 08:30:03.294523+00
714	5	846c804cd1349a68c7454aa6cefe1d578138df252ad3604d0fb6a396160cd856e11579bd9838fcd1	2026-05-21 06:23:12.474+00	t	2026-05-14 06:23:12.475287+00
719	5	8e4d12fec13f4047af603384c25b24d7789404d52023443ab6169e77341902981568e83755e23dfb	2026-05-23 03:47:15.632+00	f	2026-05-16 03:47:15.634175+00
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
14	59
14	60
14	63
14	64
14	61
14	62
14	57
14	58
14	3
14	4
14	7
14	8
14	5
14	6
14	1
14	2
14	43
14	44
14	47
14	48
14	45
14	46
14	41
14	42
14	51
14	52
14	55
14	56
14	53
14	54
14	49
14	50
14	27
14	28
14	31
14	32
14	29
14	30
14	25
14	26
14	35
14	36
14	39
14	40
14	37
14	38
14	33
14	34
14	19
14	20
14	23
14	24
14	21
14	22
14	17
14	18
14	11
14	12
14	15
14	16
14	13
14	14
14	9
14	10
14	67
14	68
14	71
14	72
14	69
14	70
14	65
14	66
1	3
1	4
1	7
1	8
1	5
1	6
1	1
1	2
1	51
1	52
1	55
1	56
1	53
1	54
1	49
1	50
1	27
1	28
1	31
1	32
1	29
1	30
1	25
1	26
1	11
1	12
1	15
1	16
1	13
1	14
1	9
1	10
1	67
1	68
1	71
1	72
1	69
1	70
1	65
1	66
1	75
1	76
1	79
1	80
1	77
1	78
1	73
1	74
1	33
1	35
1	37
1	39
14	75
14	76
14	79
14	80
14	77
14	78
14	73
14	74
6	1
6	2
6	3
6	4
6	5
6	6
6	7
6	8
6	9
6	10
6	11
6	12
6	13
6	14
6	15
6	16
6	17
6	18
6	19
6	20
6	21
6	22
6	23
6	24
6	25
6	26
6	27
6	28
6	29
6	30
6	31
6	32
6	33
6	34
6	35
6	36
6	37
6	38
6	39
6	40
6	41
6	42
6	43
6	44
6	45
6	46
6	47
6	48
6	49
6	50
6	51
6	52
6	53
6	54
6	55
6	56
6	57
6	58
6	59
6	60
6	61
6	62
6	63
6	64
6	65
6	66
6	67
6	68
6	69
6	70
6	71
6	72
6	73
6	74
6	75
6	76
6	77
6	78
6	79
6	80
8	1
8	2
8	3
8	5
8	7
8	9
8	10
8	11
8	13
8	15
8	25
8	26
5	49
5	50
5	51
5	53
5	54
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, description, is_system, created_at) FROM stdin;
1	Admin	Full system access	t	2026-04-01 05:08:23.10252+00
5	HR	Human resources access	t	2026-04-01 05:08:23.10252+00
6	Super Admin	Unrestricted access to all modules and system settings	t	2026-04-01 05:08:25.592448+00
8	Sales Executive	Field sales & CRM (same access as Agent)	t	2026-04-03 02:52:04.872087+00
14	Sales Manager	Trichy	f	2026-04-13 07:27:43.000266+00
\.


--
-- Data for Name: sale_return_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sale_return_items (id, return_id, product_id, description, quantity, unit_price, discount, gst_rate, total) FROM stdin;
\.


--
-- Data for Name: sale_return_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sale_return_payments (id, return_id, amount, payment_date, method, reference, notes, created_by, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: sale_returns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sale_returns (id, return_number, customer_id, reference_no, return_date, state_of_supply, exchange_rate, notes, subtotal, cgst, sgst, igst, discount_amount, round_off, total_amount, paid_amount, created_by, created_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: sales_order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_order_items (id, order_id, product_id, description, quantity, unit_price, gst_rate, total, discount, cgst, sgst, igst) FROM stdin;
\.


--
-- Data for Name: sales_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_orders (id, order_number, customer_id, quotation_id, status, order_date, notes, total_amount, created_by, created_at, due_date, exchange_rate, state_of_supply, discount_amount, round_off, gst_type, tax_type, is_interstate, subtotal, cgst, sgst, igst, approval_status, approved_by, approved_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (id, name, applied_at) FROM stdin;
1	001_initial_schema.sql	2026-04-01 05:08:19.922444+00
2	002_rbac.sql	2026-04-01 05:08:21.851746+00
3	003_seed_rbac.sql	2026-04-01 05:08:23.10252+00
4	004_seed_app_data.sql	2026-04-01 05:08:24.28186+00
5	005_superadmin_role.sql	2026-04-01 05:08:25.592448+00
6	006_users_role_id.sql	2026-04-01 05:08:26.82218+00
7	007_refresh_tokens.sql	2026-04-01 05:08:28.022058+00
8	008_notifications.sql	2026-04-01 05:08:29.222012+00
9	009_lead_forms_enhancements.sql	2026-04-01 05:08:30.401618+00
10	010_module_settings.sql	2026-04-01 05:08:31.612297+00
11	011_crm_enhancements.sql	2026-04-01 05:08:32.822297+00
12	012_demo_data.sql	2026-04-01 05:24:46.122238+00
13	013_fix_demo_password_hashes.sql	2026-04-01 05:24:47.811542+00
14	014_facebook_lead_pages.sql	2026-04-02 07:16:45.671402+00
15	015_facebook_lead_pages_add_url.sql	2026-04-02 07:22:57.494039+00
16	016_facebook_lead_imports.sql	2026-04-02 07:36:46.981623+00
17	017_demo_inventory_role_and_demo_users.sql	2026-04-03 02:45:07.583669+00
18	018_sales_executive_manager_roles.sql	2026-04-03 02:52:04.872087+00
19	019_notification_demo_links.sql	2026-04-03 05:05:40.037487+00
20	020_four_roles_only.sql	2026-04-04 06:56:26.937316+00
21	021_modules_crm_sales_inventory_hr.sql	2026-04-04 06:56:28.112593+00
22	022_lead_crm_fields.sql	2026-04-05 04:49:29.335071+00
23	023_company_invoice_template.sql	2026-04-08 17:04:34.816405+00
24	024_company_bank_fields.sql	2026-04-08 17:04:36.106631+00
25	023_sales_enhancements.sql	2026-04-08 18:05:52.646203+00
26	022_sales_executive_demo_employee.sql	2026-04-09 01:15:48.184163+00
27	023_attendance_user_id.sql	2026-04-09 01:29:37.374511+00
28	024_quotation_addresses.sql	2026-04-09 03:55:14.339843+00
29	024_products_catalog_fields.sql	2026-04-09 08:26:56.204638+00
30	025_product_categories_master.sql	2026-04-09 08:46:30.982955+00
31	026_leads_assigned_manager.sql	2026-04-09 12:11:51.506044+00
32	027_company_favicon.sql	2026-04-09 14:13:53.562178+00
33	028_google_sheet_lead_platform.sql	2026-04-09 14:41:49.949674+00
34	025_demo_sales_data.sql	2026-04-09 15:00:32.07599+00
35	029_lead_source_instagram.sql	2026-04-09 15:56:47.904478+00
36	030_google_sheet_data_start_row.sql	2026-04-09 15:56:49.060127+00
37	031_crm_masters.sql	2026-04-11 05:18:36.962434+00
38	032_seed_masters_from_leads.sql	2026-04-11 05:27:01.419585+00
39	033_reseed_lead_sources.sql	2026-04-11 05:31:18.029633+00
40	034_sales_returns_and_order_due_date.sql	2026-04-11 06:24:22.566062+00
41	035_orders_quotations_gst_fields.sql	2026-04-11 11:05:01.906294+00
42	036_leads_created_by.sql	2026-04-12 16:44:33.784265+00
43	037_users_avatar_url.sql	2026-04-12 16:44:35.759418+00
44	038_zones_and_user_sales_manager.sql	2026-04-13 06:07:39.891138+00
45	039_leads_sales_manager_id.sql	2026-04-14 12:07:40.198912+00
46	040_leads_drop_sales_manager_id.sql	2026-04-14 12:07:41.68898+00
47	041_company_invoice_logo.sql	2026-04-14 12:07:43.108608+00
48	042_customers_created_by.sql	2026-04-14 14:45:57.480316+00
49	043_sales_documents_approval.sql	2026-04-15 05:19:44.187882+00
50	044_customers_billing_shipping_address.sql	2026-04-15 09:03:32.445384+00
51	045_leads_product_category.sql	2026-04-15 09:03:34.034972+00
52	046_notification_push_tokens.sql	2026-04-15 15:38:57.677386+00
53	047_assign_existing_users_to_igloo_tiles_tenant.sql	2026-04-16 08:29:18.868117+00
54	048_tenant_scope_crm_sales.sql	2026-04-16 08:29:20.2584+00
55	049_tenant_scope_notifications_settings.sql	2026-04-16 08:29:21.618135+00
56	050_tenant_scope_purchase_finance_hr_inventory.sql	2026-04-16 08:29:23.098152+00
57	051_tenant_hardening_constraints.sql	2026-04-16 08:29:24.77805+00
58	052_shipping_address.sql	2026-04-16 11:43:33.358899+00
59	053_tenant_scope_communication.sql	2026-04-17 06:48:02.607977+00
60	055_quotation_sales_executive_id.sql	2026-04-17 10:50:15.105103+00
61	056_quotation_customer_addresses.sql	2026-04-17 11:09:49.625398+00
62	057_remove_customers_address_column.sql	2026-04-17 11:09:50.805255+00
63	058_company_invoice_footer_content.sql	2026-04-17 12:13:29.189393+00
64	059_lead_platforms_tenant_id.sql	2026-04-18 04:47:27.790049+00
\.


--
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock (id, product_id, warehouse_id, quantity, updated_at, tenant_id) FROM stdin;
9	44	1	20.000	2026-04-17 08:12:39.163193+00	1
14	59	1	10.000	2026-04-17 08:13:11.541182+00	1
15	52	1	10.000	2026-04-17 08:13:29.964892+00	1
16	56	1	10.000	2026-04-17 08:13:40.095594+00	1
17	58	1	10.000	2026-04-17 08:13:50.233626+00	1
\.


--
-- Data for Name: stock_movements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_movements (id, product_id, warehouse_id, type, quantity, reference, note, created_by, created_at, tenant_id) FROM stdin;
5	44	1	in	10.000	\N	\N	5	2026-04-14 17:34:37.001586+00	1
8	44	1	in	10.000	\N	\N	5	2026-04-17 08:12:39.163193+00	1
10	59	1	in	10.000	\N	\N	5	2026-04-17 08:13:11.541182+00	1
11	52	1	in	10.000	\N	\N	5	2026-04-17 08:13:29.964892+00	1
12	56	1	in	10.000	\N	\N	5	2026-04-17 08:13:40.095594+00	1
13	58	1	in	10.000	\N	\N	5	2026-04-17 08:13:50.233626+00	1
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tenants (id, name, slug, is_active, created_at, updated_at) FROM stdin;
1	igloo tiles	igloo-tiles	t	2026-04-16 08:29:18.868117+00	2026-04-16 08:29:18.868117+00
\.


--
-- Data for Name: user_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_permissions (id, user_id, permission_id) FROM stdin;
1	15	59
2	15	60
3	15	63
4	15	64
5	15	61
6	15	62
7	15	57
8	15	58
9	15	3
10	15	4
11	15	7
12	15	8
13	15	5
14	15	6
15	15	1
16	15	2
17	15	43
18	15	44
19	15	47
20	15	48
21	15	45
22	15	46
23	15	41
24	15	42
25	15	51
26	15	52
27	15	55
28	15	56
29	15	53
30	15	54
31	15	49
32	15	50
33	15	27
34	15	28
35	15	31
36	15	32
37	15	29
38	15	30
39	15	25
40	15	26
41	15	35
42	15	36
43	15	39
44	15	40
45	15	37
46	15	38
47	15	33
48	15	34
49	15	19
50	15	20
51	15	23
52	15	24
53	15	21
54	15	22
55	15	17
56	15	18
57	15	11
58	15	12
59	15	15
60	15	16
61	15	13
62	15	14
63	15	9
64	15	10
65	15	67
66	15	68
67	15	71
68	15	72
69	15	69
70	15	70
71	15	65
72	15	66
73	15	75
74	15	76
75	15	79
76	15	80
77	15	77
78	15	78
79	15	73
80	15	74
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, password, role, is_active, created_at, updated_at, role_id, avatar_url, zone_id, sales_manager_id, tenant_id) FROM stdin;
14	Padmanaban A	padmanaban@gmail.com	$2b$10$Z7UkxyF0HSr3aeCFUmwT5e6us2bGHWURbyjzJmo4940uNhCFTJfH2	Sales Executive	t	2026-04-09 11:25:50.307817+00	2026-04-16 07:04:06.266414+00	8	\N	6	15	1
1	Super Admin	super@example.com	$2b$10$lZ5A3R.E9gCL0nUU.bJvGOXurwbGCId1GbtiU0vXvwS/Fw/iJBrnG	Super Admin	t	2026-04-01 05:24:46.122238+00	2026-04-01 05:24:46.122238+00	6	\N	\N	\N	1
8	Sales Executive 1	sales.executive1@example.com	$2b$10$lZ5A3R.E9gCL0nUU.bJvGOXurwbGCId1GbtiU0vXvwS/Fw/iJBrnG	Sales Executive	f	2026-04-03 02:52:04.872087+00	2026-04-15 07:09:33.074799+00	8	/uploads/users/avatar-1776080972133.jpeg	1	15	1
16	Gokul M	igloogokul2010@gmail.com	$2b$10$6gwOaW3C4Ff1ElX5peyyk.29ccSYqRPtrxz1ZtmZ9wGYXK9mYljTC	Sales Executive	t	2026-04-13 10:56:35.524441+00	2026-04-18 07:44:40.592564+00	8	/uploads/users/avatar-1776498278574.jpg	3	15	1
5	Prem Anand D	iglootiles@yahoo.com	$2b$10$KU6bDGDeDGagM3MgoHbTn.3thYjYJwRtwkD5CiBkvLtt/zP716U6G	Admin	t	2026-04-03 02:45:07.583669+00	2026-04-19 16:56:46.37671+00	1	/uploads/bucket/users/avatars/1776617806234-rzlx0hl3.jpg	4	\N	1
15	Shankar R	iglootiles2010@gmail.com	$2b$10$2/muZ.9OcBebOxa4vPepLu5gSdnEPLbvG8mNgSnyTSRdEdROsDnum	Sales Manager	t	2026-04-13 07:28:34.819386+00	2026-04-19 17:43:23.37848+00	14	\N	5	\N	1
\.


--
-- Data for Name: vendors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendors (id, name, email, phone, gstin, address, is_active, created_at, tenant_id) FROM stdin;
1	ACME Supplies Co.	procurement@acme-vendor.demo	9876500300	29BBBBB2222B1Z2	Mumbai MH	t	2026-04-01 05:24:46.122238+00	1
2	GlassWorks India	sales@glassworks.demo	9876500400	27CCCCC3333C1Z3	Hyderabad TG	t	2026-04-01 05:24:46.122238+00	1
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.warehouses (id, name, location, is_active, tenant_id) FROM stdin;
1	Main Warehouse	Head Office	t	1
2	South Hub	Chennai ??? secondary DC	t	1
\.


--
-- Data for Name: work_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.work_orders (id, wo_number, product_id, bom_id, quantity, status, planned_start, planned_end, actual_start, actual_end, notes, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.zones (id, name, code, created_at, updated_at) FROM stdin;
1	North Region	NR	2026-04-13 06:13:00.86662+00	2026-04-13 06:13:00.86662+00
2	South Region	SR	2026-04-13 06:13:25.321243+00	2026-04-13 06:13:25.321243+00
6	Trichy Sales Executive	002	2026-04-16 07:02:12.026865+00	2026-04-16 07:02:12.026865+00
5	Tamilnadu Zonal Head	001	2026-04-16 07:00:05.972841+00	2026-04-16 07:02:22.790248+00
3	Coimbatore Zone	003	2026-04-13 06:13:49.306628+00	2026-04-16 07:03:24.068792+00
4	CEO	\N	2026-04-13 06:14:06.766852+00	2026-04-16 07:05:03.243329+00
\.


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.accounts_id_seq', 6, true);


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attendance_id_seq', 21, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 470, true);


--
-- Name: bom_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bom_id_seq', 1, true);


--
-- Name: bom_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bom_items_id_seq', 2, true);


--
-- Name: brands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.brands_id_seq', 2, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 6, true);


--
-- Name: comm_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comm_logs_id_seq', 2, true);


--
-- Name: comm_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comm_templates_id_seq', 2, true);


--
-- Name: company_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.company_settings_id_seq', 1, true);


--
-- Name: crm_platforms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crm_platforms_id_seq', 7, true);


--
-- Name: crm_priorities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crm_priorities_id_seq', 7, true);


--
-- Name: crm_segments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crm_segments_id_seq', 7, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_id_seq', 42, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employees_id_seq', 7, true);


--
-- Name: expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.expenses_id_seq', 1, false);


--
-- Name: grn_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.grn_id_seq', 1, false);


--
-- Name: grn_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.grn_items_id_seq', 1, false);


--
-- Name: invoice_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoice_items_id_seq', 13, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoices_id_seq', 76, true);


--
-- Name: journal_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.journal_entries_id_seq', 1, false);


--
-- Name: journal_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.journal_lines_id_seq', 1, false);


--
-- Name: lead_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_activities_id_seq', 1, true);


--
-- Name: lead_followups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_followups_id_seq', 19, true);


--
-- Name: lead_form_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_form_submissions_id_seq', 1, false);


--
-- Name: lead_forms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_forms_id_seq', 1, false);


--
-- Name: lead_platform_facebook_leads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_platform_facebook_leads_id_seq', 1, false);


--
-- Name: lead_platform_facebook_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_platform_facebook_pages_id_seq', 9, true);


--
-- Name: lead_platform_google_sheets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_platform_google_sheets_id_seq', 10, true);


--
-- Name: lead_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_sources_id_seq', 26, true);


--
-- Name: lead_stages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lead_stages_id_seq', 10, true);


--
-- Name: leads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.leads_id_seq', 456, true);


--
-- Name: module_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.module_settings_id_seq', 10, true);


--
-- Name: notification_push_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notification_push_tokens_id_seq', 73, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 178, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 55, true);


--
-- Name: payroll_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payroll_id_seq', 1, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permissions_id_seq', 80, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 72, true);


--
-- Name: proposal_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.proposal_items_id_seq', 1, false);


--
-- Name: proposals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.proposals_id_seq', 1, false);


--
-- Name: purchase_invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_invoices_id_seq', 1, false);


--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_order_items_id_seq', 1, true);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.purchase_orders_id_seq', 1, true);


--
-- Name: quotation_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quotation_items_id_seq', 173, true);


--
-- Name: quotations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quotations_id_seq', 65, true);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 719, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 14, true);


--
-- Name: sale_return_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sale_return_items_id_seq', 1, false);


--
-- Name: sale_return_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sale_return_payments_id_seq', 1, false);


--
-- Name: sale_returns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sale_returns_id_seq', 1, false);


--
-- Name: sales_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_order_items_id_seq', 4, true);


--
-- Name: sales_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_orders_id_seq', 5, true);


--
-- Name: schema_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.schema_migrations_id_seq', 64, true);


--
-- Name: stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_id_seq', 17, true);


--
-- Name: stock_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_movements_id_seq', 13, true);


--
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tenants_id_seq', 1, true);


--
-- Name: user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_permissions_id_seq', 80, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 16, true);


--
-- Name: vendors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vendors_id_seq', 2, true);


--
-- Name: warehouses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.warehouses_id_seq', 2, true);


--
-- Name: work_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.work_orders_id_seq', 1, true);


--
-- Name: zones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.zones_id_seq', 6, true);


--
-- Name: accounts accounts_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_code_key UNIQUE (code);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_user_id_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_user_id_date_key UNIQUE (user_id, date);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bom_items bom_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bom_items
    ADD CONSTRAINT bom_items_pkey PRIMARY KEY (id);


--
-- Name: bom bom_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bom
    ADD CONSTRAINT bom_pkey PRIMARY KEY (id);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: comm_logs comm_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_logs
    ADD CONSTRAINT comm_logs_pkey PRIMARY KEY (id);


--
-- Name: comm_templates comm_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_templates
    ADD CONSTRAINT comm_templates_pkey PRIMARY KEY (id);


--
-- Name: company_settings company_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_settings
    ADD CONSTRAINT company_settings_pkey PRIMARY KEY (id);


--
-- Name: crm_platforms crm_platforms_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_platforms
    ADD CONSTRAINT crm_platforms_name_key UNIQUE (name);


--
-- Name: crm_platforms crm_platforms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_platforms
    ADD CONSTRAINT crm_platforms_pkey PRIMARY KEY (id);


--
-- Name: crm_priorities crm_priorities_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_priorities
    ADD CONSTRAINT crm_priorities_name_key UNIQUE (name);


--
-- Name: crm_priorities crm_priorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_priorities
    ADD CONSTRAINT crm_priorities_pkey PRIMARY KEY (id);


--
-- Name: crm_segments crm_segments_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_segments
    ADD CONSTRAINT crm_segments_name_key UNIQUE (name);


--
-- Name: crm_segments crm_segments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crm_segments
    ADD CONSTRAINT crm_segments_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: employees employees_employee_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_employee_code_key UNIQUE (employee_code);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: employees employees_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_key UNIQUE (user_id);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: grn grn_grn_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn
    ADD CONSTRAINT grn_grn_number_key UNIQUE (grn_number);


--
-- Name: grn_items grn_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_pkey PRIMARY KEY (id);


--
-- Name: grn grn_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn
    ADD CONSTRAINT grn_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: journal_entries journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- Name: journal_lines journal_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_pkey PRIMARY KEY (id);


--
-- Name: lead_activities lead_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_activities
    ADD CONSTRAINT lead_activities_pkey PRIMARY KEY (id);


--
-- Name: lead_followups lead_followups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_followups
    ADD CONSTRAINT lead_followups_pkey PRIMARY KEY (id);


--
-- Name: lead_form_submissions lead_form_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_form_submissions
    ADD CONSTRAINT lead_form_submissions_pkey PRIMARY KEY (id);


--
-- Name: lead_forms lead_forms_form_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_forms
    ADD CONSTRAINT lead_forms_form_key_key UNIQUE (form_key);


--
-- Name: lead_forms lead_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_forms
    ADD CONSTRAINT lead_forms_pkey PRIMARY KEY (id);


--
-- Name: lead_platform_facebook_leads lead_platform_facebook_leads_facebook_lead_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_leads
    ADD CONSTRAINT lead_platform_facebook_leads_facebook_lead_id_key UNIQUE (facebook_lead_id);


--
-- Name: lead_platform_facebook_leads lead_platform_facebook_leads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_leads
    ADD CONSTRAINT lead_platform_facebook_leads_pkey PRIMARY KEY (id);


--
-- Name: lead_platform_facebook_pages lead_platform_facebook_pages_page_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_pages
    ADD CONSTRAINT lead_platform_facebook_pages_page_id_key UNIQUE (page_id);


--
-- Name: lead_platform_facebook_pages lead_platform_facebook_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_pages
    ADD CONSTRAINT lead_platform_facebook_pages_pkey PRIMARY KEY (id);


--
-- Name: lead_platform_google_sheets lead_platform_google_sheets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_google_sheets
    ADD CONSTRAINT lead_platform_google_sheets_pkey PRIMARY KEY (id);


--
-- Name: lead_sources lead_sources_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_sources
    ADD CONSTRAINT lead_sources_name_key UNIQUE (name);


--
-- Name: lead_sources lead_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_sources
    ADD CONSTRAINT lead_sources_pkey PRIMARY KEY (id);


--
-- Name: lead_stages lead_stages_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_stages
    ADD CONSTRAINT lead_stages_name_key UNIQUE (name);


--
-- Name: lead_stages lead_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_stages
    ADD CONSTRAINT lead_stages_pkey PRIMARY KEY (id);


--
-- Name: leads leads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_pkey PRIMARY KEY (id);


--
-- Name: module_settings module_settings_module_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_settings
    ADD CONSTRAINT module_settings_module_key UNIQUE (module);


--
-- Name: module_settings module_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_settings
    ADD CONSTRAINT module_settings_pkey PRIMARY KEY (id);


--
-- Name: notification_push_tokens notification_push_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_push_tokens
    ADD CONSTRAINT notification_push_tokens_pkey PRIMARY KEY (id);


--
-- Name: notification_push_tokens notification_push_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_push_tokens
    ADD CONSTRAINT notification_push_tokens_token_key UNIQUE (token);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payroll payroll_employee_id_month_year_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_employee_id_month_year_key UNIQUE (employee_id, month, year);


--
-- Name: payroll payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_module_action_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_module_action_key UNIQUE (module, action);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: proposal_items proposal_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposal_items
    ADD CONSTRAINT proposal_items_pkey PRIMARY KEY (id);


--
-- Name: proposals proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_pkey PRIMARY KEY (id);


--
-- Name: proposals proposals_proposal_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_proposal_number_key UNIQUE (proposal_number);


--
-- Name: purchase_invoices purchase_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_invoices
    ADD CONSTRAINT purchase_invoices_pkey PRIMARY KEY (id);


--
-- Name: purchase_order_items purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_po_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_po_number_key UNIQUE (po_number);


--
-- Name: quotation_items quotation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_pkey PRIMARY KEY (id);


--
-- Name: quotations quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_pkey PRIMARY KEY (id);


--
-- Name: quotations quotations_quotation_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_quotation_number_key UNIQUE (quotation_number);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sale_return_items sale_return_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_pkey PRIMARY KEY (id);


--
-- Name: sale_return_payments sale_return_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_payments
    ADD CONSTRAINT sale_return_payments_pkey PRIMARY KEY (id);


--
-- Name: sale_returns sale_returns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_pkey PRIMARY KEY (id);


--
-- Name: sale_returns sale_returns_return_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_return_number_key UNIQUE (return_number);


--
-- Name: sales_order_items sales_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_pkey PRIMARY KEY (id);


--
-- Name: sales_orders sales_orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_order_number_key UNIQUE (order_number);


--
-- Name: sales_orders sales_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_name_key UNIQUE (name);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (id);


--
-- Name: stock_movements stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);


--
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (id);


--
-- Name: stock stock_product_id_warehouse_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_product_id_warehouse_id_key UNIQUE (product_id, warehouse_id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_slug_key UNIQUE (slug);


--
-- Name: user_permissions user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_pkey PRIMARY KEY (id);


--
-- Name: user_permissions user_permissions_user_id_permission_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_user_id_permission_id_key UNIQUE (user_id, permission_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_pkey PRIMARY KEY (id);


--
-- Name: work_orders work_orders_wo_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_wo_number_key UNIQUE (wo_number);


--
-- Name: zones zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);


--
-- Name: idx_attendance_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_attendance_tenant_id ON public.attendance USING btree (tenant_id);


--
-- Name: idx_comm_logs_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comm_logs_tenant_id ON public.comm_logs USING btree (tenant_id);


--
-- Name: idx_comm_templates_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_comm_templates_tenant_id ON public.comm_templates USING btree (tenant_id);


--
-- Name: idx_company_settings_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_company_settings_tenant_id ON public.company_settings USING btree (tenant_id);


--
-- Name: idx_customers_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_customers_tenant_id ON public.customers USING btree (tenant_id);


--
-- Name: idx_employees_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_employees_tenant_id ON public.employees USING btree (tenant_id);


--
-- Name: idx_expenses_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_expenses_tenant_id ON public.expenses USING btree (tenant_id);


--
-- Name: idx_invoices_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invoices_tenant_id ON public.invoices USING btree (tenant_id);


--
-- Name: idx_journal_entries_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journal_entries_tenant_id ON public.journal_entries USING btree (tenant_id);


--
-- Name: idx_lead_activities_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_activities_tenant_id ON public.lead_activities USING btree (tenant_id);


--
-- Name: idx_lead_followups_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_followups_tenant_id ON public.lead_followups USING btree (tenant_id);


--
-- Name: idx_lead_platform_facebook_leads_form; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_facebook_leads_form ON public.lead_platform_facebook_leads USING btree (form_id);


--
-- Name: idx_lead_platform_facebook_leads_page; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_facebook_leads_page ON public.lead_platform_facebook_leads USING btree (page_id);


--
-- Name: idx_lead_platform_facebook_leads_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_facebook_leads_tenant_id ON public.lead_platform_facebook_leads USING btree (tenant_id);


--
-- Name: idx_lead_platform_facebook_pages_page_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_facebook_pages_page_url ON public.lead_platform_facebook_pages USING btree (page_url);


--
-- Name: idx_lead_platform_facebook_pages_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_facebook_pages_source ON public.lead_platform_facebook_pages USING btree (lead_source_id);


--
-- Name: idx_lead_platform_facebook_pages_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_facebook_pages_tenant_id ON public.lead_platform_facebook_pages USING btree (tenant_id);


--
-- Name: idx_lead_platform_google_sheets_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_google_sheets_source ON public.lead_platform_google_sheets USING btree (lead_source_id);


--
-- Name: idx_lead_platform_google_sheets_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lead_platform_google_sheets_tenant_id ON public.lead_platform_google_sheets USING btree (tenant_id);


--
-- Name: idx_leads_assigned_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_assigned_to ON public.leads USING btree (assigned_to);


--
-- Name: idx_leads_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_created_by ON public.leads USING btree (created_by);


--
-- Name: idx_leads_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_tenant_id ON public.leads USING btree (tenant_id);


--
-- Name: idx_module_settings_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_module_settings_tenant_id ON public.module_settings USING btree (tenant_id);


--
-- Name: idx_notification_push_tokens_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_push_tokens_tenant_id ON public.notification_push_tokens USING btree (tenant_id);


--
-- Name: idx_notification_push_tokens_user_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_push_tokens_user_active ON public.notification_push_tokens USING btree (user_id, is_active);


--
-- Name: idx_notifications_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_tenant_id ON public.notifications USING btree (tenant_id);


--
-- Name: idx_notifications_user_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notifications_user_unread ON public.notifications USING btree (user_id, is_read);


--
-- Name: idx_payments_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_tenant_id ON public.payments USING btree (tenant_id);


--
-- Name: idx_payroll_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payroll_tenant_id ON public.payroll USING btree (tenant_id);


--
-- Name: idx_purchase_orders_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_purchase_orders_tenant_id ON public.purchase_orders USING btree (tenant_id);


--
-- Name: idx_quotations_sales_executive_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotations_sales_executive_id ON public.quotations USING btree (sales_executive_id);


--
-- Name: idx_quotations_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quotations_tenant_id ON public.quotations USING btree (tenant_id);


--
-- Name: idx_refresh_tokens_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refresh_tokens_token ON public.refresh_tokens USING btree (token);


--
-- Name: idx_refresh_tokens_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refresh_tokens_user ON public.refresh_tokens USING btree (user_id);


--
-- Name: idx_sale_return_payments_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sale_return_payments_tenant_id ON public.sale_return_payments USING btree (tenant_id);


--
-- Name: idx_sale_returns_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sale_returns_tenant_id ON public.sale_returns USING btree (tenant_id);


--
-- Name: idx_sales_orders_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sales_orders_tenant_id ON public.sales_orders USING btree (tenant_id);


--
-- Name: idx_users_sales_manager_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_sales_manager_id ON public.users USING btree (sales_manager_id);


--
-- Name: idx_users_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_tenant_id ON public.users USING btree (tenant_id);


--
-- Name: idx_users_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_zone_id ON public.users USING btree (zone_id);


--
-- Name: idx_vendors_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vendors_tenant_id ON public.vendors USING btree (tenant_id);


--
-- Name: uq_brands_tenant_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_brands_tenant_name ON public.brands USING btree (tenant_id, name);


--
-- Name: uq_categories_tenant_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_categories_tenant_name ON public.categories USING btree (tenant_id, name);


--
-- Name: uq_products_tenant_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_products_tenant_code ON public.products USING btree (tenant_id, code) WHERE (code IS NOT NULL);


--
-- Name: uq_products_tenant_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_products_tenant_sku ON public.products USING btree (tenant_id, sku) WHERE (sku IS NOT NULL);


--
-- Name: uq_users_tenant_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_users_tenant_email ON public.users USING btree (tenant_id, email);


--
-- Name: zones_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX zones_code_unique ON public.zones USING btree (code) WHERE ((code IS NOT NULL) AND (TRIM(BOTH FROM code) <> ''::text));


--
-- Name: users trg_sync_user_role_name; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_sync_user_role_name BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.sync_user_role_name();


--
-- Name: accounts accounts_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: accounts accounts_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: attendance attendance_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: attendance attendance_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: bom_items bom_items_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bom_items
    ADD CONSTRAINT bom_items_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.bom(id) ON DELETE CASCADE;


--
-- Name: bom_items bom_items_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bom_items
    ADD CONSTRAINT bom_items_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: bom bom_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bom
    ADD CONSTRAINT bom_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: brands brands_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: categories categories_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: comm_logs comm_logs_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_logs
    ADD CONSTRAINT comm_logs_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.leads(id) ON DELETE SET NULL;


--
-- Name: comm_logs comm_logs_sent_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_logs
    ADD CONSTRAINT comm_logs_sent_by_fkey FOREIGN KEY (sent_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: comm_logs comm_logs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_logs
    ADD CONSTRAINT comm_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: comm_templates comm_templates_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comm_templates
    ADD CONSTRAINT comm_templates_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: company_settings company_settings_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company_settings
    ADD CONSTRAINT company_settings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: customers customers_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: customers customers_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.leads(id) ON DELETE SET NULL;


--
-- Name: customers customers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: employees employees_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: employees employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: expenses expenses_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: grn grn_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn
    ADD CONSTRAINT grn_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: grn_items grn_items_grn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_grn_id_fkey FOREIGN KEY (grn_id) REFERENCES public.grn(id) ON DELETE CASCADE;


--
-- Name: grn_items grn_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: grn_items grn_items_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: grn_items grn_items_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: grn grn_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn
    ADD CONSTRAINT grn_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.purchase_orders(id) ON DELETE RESTRICT;


--
-- Name: grn grn_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grn
    ADD CONSTRAINT grn_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: invoices invoices_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.sales_orders(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: journal_entries journal_entries_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: journal_entries journal_entries_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: journal_lines journal_lines_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE RESTRICT;


--
-- Name: journal_lines journal_lines_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_entry_id_fkey FOREIGN KEY (entry_id) REFERENCES public.journal_entries(id) ON DELETE CASCADE;


--
-- Name: journal_lines journal_lines_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: lead_activities lead_activities_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_activities
    ADD CONSTRAINT lead_activities_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.leads(id) ON DELETE CASCADE;


--
-- Name: lead_activities lead_activities_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_activities
    ADD CONSTRAINT lead_activities_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: lead_activities lead_activities_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_activities
    ADD CONSTRAINT lead_activities_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: lead_followups lead_followups_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_followups
    ADD CONSTRAINT lead_followups_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: lead_followups lead_followups_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_followups
    ADD CONSTRAINT lead_followups_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.leads(id) ON DELETE CASCADE;


--
-- Name: lead_followups lead_followups_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_followups
    ADD CONSTRAINT lead_followups_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: lead_form_submissions lead_form_submissions_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_form_submissions
    ADD CONSTRAINT lead_form_submissions_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.lead_forms(id) ON DELETE CASCADE;


--
-- Name: lead_form_submissions lead_form_submissions_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_form_submissions
    ADD CONSTRAINT lead_form_submissions_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.leads(id) ON DELETE SET NULL;


--
-- Name: lead_forms lead_forms_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_forms
    ADD CONSTRAINT lead_forms_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: lead_forms lead_forms_default_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_forms
    ADD CONSTRAINT lead_forms_default_source_id_fkey FOREIGN KEY (default_source_id) REFERENCES public.lead_sources(id) ON DELETE SET NULL;


--
-- Name: lead_forms lead_forms_default_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_forms
    ADD CONSTRAINT lead_forms_default_stage_id_fkey FOREIGN KEY (default_stage_id) REFERENCES public.lead_stages(id) ON DELETE SET NULL;


--
-- Name: lead_platform_facebook_leads lead_platform_facebook_leads_crm_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_leads
    ADD CONSTRAINT lead_platform_facebook_leads_crm_lead_id_fkey FOREIGN KEY (crm_lead_id) REFERENCES public.leads(id) ON DELETE SET NULL;


--
-- Name: lead_platform_facebook_leads lead_platform_facebook_leads_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_leads
    ADD CONSTRAINT lead_platform_facebook_leads_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: lead_platform_facebook_pages lead_platform_facebook_pages_lead_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_pages
    ADD CONSTRAINT lead_platform_facebook_pages_lead_source_id_fkey FOREIGN KEY (lead_source_id) REFERENCES public.lead_sources(id) ON DELETE SET NULL;


--
-- Name: lead_platform_facebook_pages lead_platform_facebook_pages_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_facebook_pages
    ADD CONSTRAINT lead_platform_facebook_pages_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: lead_platform_google_sheets lead_platform_google_sheets_lead_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_google_sheets
    ADD CONSTRAINT lead_platform_google_sheets_lead_source_id_fkey FOREIGN KEY (lead_source_id) REFERENCES public.lead_sources(id) ON DELETE SET NULL;


--
-- Name: lead_platform_google_sheets lead_platform_google_sheets_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_platform_google_sheets
    ADD CONSTRAINT lead_platform_google_sheets_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: leads leads_assigned_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_assigned_manager_id_fkey FOREIGN KEY (assigned_manager_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: leads leads_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: leads leads_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: leads leads_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.lead_sources(id) ON DELETE SET NULL;


--
-- Name: leads leads_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.lead_stages(id) ON DELETE SET NULL;


--
-- Name: leads leads_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: module_settings module_settings_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_settings
    ADD CONSTRAINT module_settings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: notification_push_tokens notification_push_tokens_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_push_tokens
    ADD CONSTRAINT notification_push_tokens_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: notification_push_tokens notification_push_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_push_tokens
    ADD CONSTRAINT notification_push_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE RESTRICT;


--
-- Name: payments payments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: payroll payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE RESTRICT;


--
-- Name: payroll payroll_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: products products_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id) ON DELETE SET NULL;


--
-- Name: products products_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: proposal_items proposal_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposal_items
    ADD CONSTRAINT proposal_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: proposal_items proposal_items_proposal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposal_items
    ADD CONSTRAINT proposal_items_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES public.proposals(id) ON DELETE CASCADE;


--
-- Name: proposals proposals_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: proposals proposals_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: proposals proposals_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.leads(id) ON DELETE SET NULL;


--
-- Name: purchase_invoices purchase_invoices_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_invoices
    ADD CONSTRAINT purchase_invoices_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.purchase_orders(id) ON DELETE SET NULL;


--
-- Name: purchase_invoices purchase_invoices_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_invoices
    ADD CONSTRAINT purchase_invoices_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: purchase_invoices purchase_invoices_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_invoices
    ADD CONSTRAINT purchase_invoices_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id) ON DELETE RESTRICT;


--
-- Name: purchase_order_items purchase_order_items_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.purchase_orders(id) ON DELETE CASCADE;


--
-- Name: purchase_order_items purchase_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: purchase_order_items purchase_order_items_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: purchase_orders purchase_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: purchase_orders purchase_orders_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: purchase_orders purchase_orders_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id) ON DELETE RESTRICT;


--
-- Name: quotation_items quotation_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: quotation_items quotation_items_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_quotation_id_fkey FOREIGN KEY (quotation_id) REFERENCES public.quotations(id) ON DELETE CASCADE;


--
-- Name: quotations quotations_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: quotations quotations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: quotations quotations_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: quotations quotations_proposal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES public.proposals(id) ON DELETE SET NULL;


--
-- Name: quotations quotations_sales_executive_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_sales_executive_id_fkey FOREIGN KEY (sales_executive_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: quotations quotations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: sale_return_items sale_return_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: sale_return_items sale_return_items_return_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_return_id_fkey FOREIGN KEY (return_id) REFERENCES public.sale_returns(id) ON DELETE CASCADE;


--
-- Name: sale_return_payments sale_return_payments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_payments
    ADD CONSTRAINT sale_return_payments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: sale_return_payments sale_return_payments_return_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_payments
    ADD CONSTRAINT sale_return_payments_return_id_fkey FOREIGN KEY (return_id) REFERENCES public.sale_returns(id) ON DELETE RESTRICT;


--
-- Name: sale_return_payments sale_return_payments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_return_payments
    ADD CONSTRAINT sale_return_payments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: sale_returns sale_returns_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: sale_returns sale_returns_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: sale_returns sale_returns_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: sales_order_items sales_order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.sales_orders(id) ON DELETE CASCADE;


--
-- Name: sales_order_items sales_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: sales_orders sales_orders_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: sales_orders sales_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: sales_orders sales_orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: sales_orders sales_orders_quotation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_quotation_id_fkey FOREIGN KEY (quotation_id) REFERENCES public.quotations(id) ON DELETE SET NULL;


--
-- Name: sales_orders sales_orders_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: stock_movements stock_movements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: stock_movements stock_movements_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: stock_movements stock_movements_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: stock_movements stock_movements_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: stock stock_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: stock stock_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: stock stock_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE SET NULL;


--
-- Name: users users_sales_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_sales_manager_id_fkey FOREIGN KEY (sales_manager_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users users_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: users users_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.zones(id) ON DELETE SET NULL;


--
-- Name: vendors vendors_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: warehouses warehouses_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;


--
-- Name: work_orders work_orders_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.bom(id) ON DELETE SET NULL;


--
-- Name: work_orders work_orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: work_orders work_orders_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_orders
    ADD CONSTRAINT work_orders_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict wlcFucuztKtrfCQcFaO5rQwUOVXgqFY1fq1ladgi6EuVWEC5JrJoApvWcAhZZyq

