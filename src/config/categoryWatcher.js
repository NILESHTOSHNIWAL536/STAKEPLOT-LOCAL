const chokidar = require('chokidar');
const path = require('path');
const categoryUpdatedQueue = require('./queue-config');

const categoriesPath = path.join(__dirname, 'categories.js');

const initCategoryWatcher = () => {
  const watcher = chokidar.watch(categoriesPath, { ignoreInitial: true });

  watcher.on('change', async () => {
    console.log('📁 categories.js changed → publishing event');

    // Clear cache to force fresh load
    delete require.cache[require.resolve(categoriesPath)];

    // Load updated JS module
    const newConfig = require(categoriesPath);

    // Add job to BullMQ queue
    await categoryUpdatedQueue.add('CATEGORIES_UPDATED', {
      timestamp: Date.now(),
      newCategories: newConfig,
    });

    console.log('✅ Job added to queue');
  });

};

module.exports = initCategoryWatcher;
