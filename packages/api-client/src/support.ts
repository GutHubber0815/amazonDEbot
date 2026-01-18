import { getSupabase } from './client';
import type { SupportContact } from '@early-help/types';

/**
 * Get all support contacts
 */
export async function getSupportContacts(): Promise<SupportContact[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('support_contacts')
    .select('*')
    .order('name', { ascending: true });

  if (error) throw error;
  return data || [];
}

/**
 * Get support contact by ID
 */
export async function getSupportContactById(id: string): Promise<SupportContact | null> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('support_contacts')
    .select('*')
    .eq('id', id)
    .single();

  if (error) {
    if (error.code === 'PGRST116') return null;
    throw error;
  }
  return data;
}

/**
 * Create support contact - admin only
 */
export async function createSupportContact(contact: Omit<SupportContact, 'id' | 'created_at' | 'updated_at'>): Promise<SupportContact> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('support_contacts')
    .insert(contact)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Update support contact - admin only
 */
export async function updateSupportContact(id: string, updates: Partial<SupportContact>): Promise<SupportContact> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('support_contacts')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Delete support contact - admin only
 */
export async function deleteSupportContact(id: string): Promise<void> {
  const supabase = getSupabase();
  const { error } = await supabase
    .from('support_contacts')
    .delete()
    .eq('id', id);

  if (error) throw error;
}
