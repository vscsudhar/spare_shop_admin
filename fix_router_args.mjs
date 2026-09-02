import fs from 'fs';
import path from 'path';

const files = [
  'd:/sudharsan/spare_shop_admin/lib/app/app.router.dart',
  'd:/sudharsan/spare_shop/lib/app/app.router.dart'
];

for (const filePath of files) {
  if (!fs.existsSync(filePath)) continue;
  let content = fs.readFileSync(filePath, 'utf8');

  // Replace nullOk: false occurrences with safe orElse fallbacks
  // Pattern: final args = data.getArgs<SomeArguments>(nullOk: false);
  const regex = /final args =\s*data\.getArgs<(\w+)>\(nullOk:\s*false\);/g;

  content = content.replace(regex, (match, typeName) => {
    return `final args = data.getArgs<${typeName}>(\n        orElse: () => const ${typeName}(requestId: '', supplierId: '', quotationId: '', orderId: '', productId: '', categoryId: '', brandId: '', modelId: ''),\n      );`;
  });

  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`✅ Safe getArgs updated in ${path.basename(filePath)}`);
}
