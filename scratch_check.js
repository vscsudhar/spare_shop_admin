const mongoose = require('d:/sudharsan/spare_api/node_modules/mongoose');

async function run() {
  try {
    await mongoose.connect('mongodb://127.0.0.1:27017/voltspare');
    console.log('Connected to MongoDB');
    const settings = await mongoose.connection.db.collection('settings').findOne({});
    console.log('--- Settings Document ---');
    console.log(JSON.stringify(settings, null, 2));
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await mongoose.connection.close();
  }
}

run();
