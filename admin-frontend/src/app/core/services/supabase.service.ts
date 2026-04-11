import { Injectable } from '@angular/core';
import { createClient, SupabaseClient, Session } from '@supabase/supabase-js';
import { environment } from '../../../environments/environment';


@Injectable({
  providedIn: 'root'
})
export class SupabaseService {
  private supabase: SupabaseClient;

  constructor() {
    this.supabase = createClient(environment.supabaseUrl, environment.supabaseKey, {
      auth: {
        detectSessionInUrl: true,
        flowType: 'implicit',
      }
    });
  }

  get client(): SupabaseClient {
    return this.supabase;
  }

  signInWithPassword(email: string, password: string) {
    return this.supabase.auth.signInWithPassword({ email, password });
  }

  signUp(email: string, password: string) {
    return this.supabase.auth.signUp({ email, password });
  }

  signOut() {
    return this.supabase.auth.signOut();
  }

  getSession() {
    return this.supabase.auth.getSession();
  }

  resetPasswordForEmail(email: string) {
    return this.supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${environment.siteUrl}/auth/set-new-password`,
    });
  }

  updateUser(attributes: { password?: string }) {
    return this.supabase.auth.updateUser(attributes);
  }

  onAuthStateChange(callback: (event: string, session: Session | null) => void) {
    return this.supabase.auth.onAuthStateChange(callback);
  }
}
