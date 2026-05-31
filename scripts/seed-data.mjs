// Run: SUPABASE_SERVICE_ROLE_KEY=your_key node scripts/seed-data.mjs
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://mcelqinrwenlsxsyoqxs.supabase.co',
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

console.log('Seeding test data...');

// 1. Get superadmin user id
const { data: adminUser } = await supabase
  .from('tnc_users').select('id').eq('username', 'superadmin').single();
const userId = adminUser?.id;
console.log('Admin user:', userId);

// 2. Get document types
const { data: docTypes } = await supabase
  .from('document_types').select('id, code, prefix');
const quotationType = docTypes.find(d => d.code === 'QUOTATION');
console.log('Quotation type:', quotationType?.id);

// 3. Insert test customers
const { data: customers, error: custError } = await supabase
  .from('customers')
  .upsert([
    {
      customer_code: '005212',
      company_name: 'เมนสเคปคลินิกเวชกรรมสาขาชิดลม',
      contact_name: 'คุณมานะ',
      address: '518/5 อาคารมณียาเซ็นเตอร์ ชั้น M ล็อคที่ 125 ถนนเพลินจิต แขวงลุมพินี เขตปทุมวัน กรุงเทพมหานคร 10330',
      phone: '02-XXX-XXXX',
      tax_id: '010556XXXXXXX',
      email: 'info@menscape.co.th',
      created_by: userId,
    },
    {
      customer_code: 'X0254',
      company_name: 'บริษัท ดีอัลเนอร์ จำกัด (สำนักงานใหญ่)',
      contact_name: 'คุณสมชาย',
      address: '188/47 หมู่ 8 ตำบลบางคูวัด อำเภอเมืองปทุมธานี จังหวัดปทุมธานี 12000',
      phone: '02-XXX-XXXX',
      tax_id: '0135568007488',
      created_by: userId,
    },
  ], { onConflict: 'customer_code' })
  .select();

if (custError) { console.error('Customer error:', custError); } 
else { console.log('Customers created:', customers?.length); }

const customer = customers?.[0];

// 4. Insert test document (BOQ - Menscape style)
if (quotationType && customer && userId) {
  // Generate doc number
  const buddhistYear = new Date().getFullYear() + 543;
  const { data: seq } = await supabase
    .from('document_sequences')
    .select('id, last_number')
    .eq('document_type_id', quotationType.id)
    .eq('year', buddhistYear)
    .maybeSingle();

  let nextNum = 1;
  if (seq) {
    nextNum = seq.last_number + 1;
    await supabase.from('document_sequences').update({ last_number: nextNum }).eq('id', seq.id);
  } else {
    await supabase.from('document_sequences').insert({ document_type_id: quotationType.id, year: buddhistYear, last_number: 1 });
  }
  const docNumber = `${quotationType.prefix}${String(nextNum).padStart(4,'0')}/${buddhistYear}`;

  const { data: doc, error: docError } = await supabase
    .from('documents')
    .insert({
      document_number: docNumber,
      document_type_id: quotationType.id,
      customer_id: customer.id,
      status: 'draft',
      language: 'th',
      issue_date: new Date().toISOString().split('T')[0],
      payment_condition: '30% เมื่อตกลงทำสัญญา\n20% เมื่อผนังแล้วเสร็จ\n30% เมื่อติดตั้งเฟอร์นิเจอร์\n20% เมื่อส่งมอบงาน',
      notes: '- กรณีต่างจังหวัด ลูกค้าเป็นผู้จัดหาที่พักพนักงาน\n- ราคานี้ไม่รวมงานที่ไม่มีอยู่ในใบเสนอราคา\n- ราคาดังกล่าวอาจมีการเปลี่ยนแปลงหลังจากเข้าหน้างาน',
      subtotal: 9215000,
      discount_design: 199200,
      discount_trade: 0,
      price_before_vat: 9015800,
      vat_amount: 631106,
      total_amount: 9646906,
      created_by: userId,
      issued_by: userId,
    })
    .select().single();

  if (docError) { console.error('Doc error:', docError); }
  else {
    console.log('Document created:', doc.document_number, doc.id);

    // 5. Insert categories
    const { data: cats } = await supabase
      .from('document_categories')
      .insert([
        { document_id: doc.id, category_number: 1, name_th: 'หมวดงานสถาปัตยกรรม', sort_order: 0 },
        { document_id: doc.id, category_number: 2, name_th: 'หมวดงานเฟอร์นิเจอร์', sort_order: 1 },
        { document_id: doc.id, category_number: 3, name_th: 'หมวดงานกราฟฟิคและป้ายต่างๆ', sort_order: 2 },
        { document_id: doc.id, category_number: 4, name_th: 'หมวดงานขนส่ง กทม. และเตรียมพื้นที่', sort_order: 3 },
      ])
      .select();

    console.log('Categories created:', cats?.length);

    // 6. Insert sample items for category 1
    if (cats?.[0]) {
      const c1 = cats[0].id;
      await supabase.from('document_items').insert([
        { document_id: doc.id, category_id: c1, item_number: '1.1', item_code: '01', description_th: 'งานรื้อป้าย และ ไฟฉุกเฉิน เพื่อติดตั้งในตำแหน่งใหม่', quantity: 1, unit_th: 'งาน', unit_price: 0, amount: 0, sort_order: 0 },
        { document_id: doc.id, category_id: c1, item_number: '1.2', item_code: '02', description_th: 'งานรื้อถอนประตูบานสวิงทางเข้าเดิม', quantity: 1, unit_th: 'งาน', unit_price: 100000, amount: 100000, sort_order: 1 },
        { document_id: doc.id, category_id: c1, item_number: '1.5', item_code: 'FL1', description_th: 'กระเบื้องยาง Polyflor Code : 2990 Oiled Oak', quantity: 531, unit_th: 'ตร.ม.', unit_price: 1500, amount: 796500, sort_order: 2 },
        { document_id: doc.id, category_id: c1, item_number: '1.6', description_th: 'งานปรับ Self-Leveling พื้น', quantity: 531, unit_th: 'ตร.ม.', unit_price: 500, amount: 265500, sort_order: 3 },
        { document_id: doc.id, category_id: c1, item_number: '', description_th: 'รวมราคางานสถาปัตยกรรม', quantity: 0, unit_th: '', unit_price: 0, amount: 1162000, is_subtotal_row: true, sort_order: 4 },
      ]);
      console.log('Items created for category 1');
    }

    // Log
    await supabase.from('export_logs').insert({
      document_id: doc.id, action: 'draft_saved', performed_by: userId, notes: 'Seed data'
    });
  }
}

console.log('\nDone! Test data seeded.');
console.log('Login at http://localhost:4321/documents');
console.log('Username: superadmin / Password: TNC@2024!');
