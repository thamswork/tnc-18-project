// Run this ONCE to create the first superadmin user
// Usage: node scripts/create-admin.mjs
// Then you can add more users via the admin UI

import bcrypt from 'bcryptjs';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://mcelqinrwenlsxsyoqxs.supabase.co';
// Paste your service_role key here (from Supabase → Settings → API)
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!serviceRoleKey) {
  console.error('❌ Set SUPABASE_SERVICE_ROLE_KEY env variable first');
  console.error('   Run: SUPABASE_SERVICE_ROLE_KEY=your_key node scripts/create-admin.mjs');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, serviceRoleKey);

const users = [
  {
    username: 'superadmin',
    password: 'TNC@2024!', // Change this!
    full_name: 'TNC Super Admin',
    role: 'superadmin',
  },
];

for (const user of users) {
  const password_hash = await bcrypt.hash(user.password, 10);
  
  const { data, error } = await supabase
    .from('tnc_users')
    .upsert({ 
      username: user.username, 
      password_hash, 
      full_name: user.full_name, 
      role: user.role,
      is_active: true,
    }, { onConflict: 'username' })
    .select('id, username, role');

  if (error) {
    console.error(`❌ Failed to create ${user.username}:`, error.message);
  } else {
    console.log(`✅ Created user: ${user.username} (${user.role})`);
    console.log(`   Password: ${user.password}`);
  }
}

console.log('\n✅ Done! Login at: https://tncbuildstudio.com/documents');
console.log('⚠️  Change the default password after first login!');
