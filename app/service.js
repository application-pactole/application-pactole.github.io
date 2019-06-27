'use strict'

function log(msg) {
  console.log(`* ${msg}`)
}

oninstall = event => {
  log('Installing service...')
  log('...service installed.')
}

onactivate = event => {
  log('Activating service...')
  if (!database) {
    event.waitUntil(
      openDatabase().then(msg => {
        log('Datastore opened.')
        return clients.claim()
      }),
    )
  } else {
    event.waitUntil(clients.claim())
  }
  log('...service activated.')
}

onfetch = event => {
  //log(`Fetch: ${event.request.url}`)
  switch (event.request.url) {
    case 'http://localhost:8383/accounts.json':
      event.respondWith(new Response('{"name": "foobar"}'))
    default:
  }
  //  event.respondWith(
  //    caches.match(event.request)
  //      .then(function(response) {
  //         if (response) {
  //           return response
  //         }
  //        return fetch(event.request)
  //      }
  //    )
  //  )
}

onmessage = event => {
  log(`Received ${event.data.msg}.`)
  switch (event.data.msg) {
    case 'connect':
      sendUpdateAccounts()
      send({ msg: 'update' })
      break
    case 'get accounts':
      log('sending accounts reply')
      event.ports[0].postMessage({
        msg: 'accounts',
        accounts: dummyAccounts,
      })
      break
    case 'get categories':
      log('sending categories reply')
      event.ports[0].postMessage({
        msg: 'categories',
        categories: dummyCategories,
      })
      break
    case 'get transactions':
      log('sending transactions reply')
      event.ports[0].postMessage({
        msg: 'transactions',
        transactions: dummyTransactions,
      })
      break
    case 'new transaction':
      dummyTransactions.push(event.data.transaction)
      event.ports[0].postMessage({ msg: 'done' })
      send({ msg: 'update' })
      break
  }
}

async function send(message) {
  const all = await clients.matchAll({
    includeUnctonrolled: true,
  })
  log(`Sending ${message.msg} to ${all.length} client(s)...`)
  for (const c of all) {
    c.postMessage(message)
  }
}

async function getAll(osName) {
  return new Promise(function(resolve, reject) {
    if (database === null) {
      reject(new Error('datastore not opened'))
    }

    let tr = database.transaction(osName, 'readonly')
    tr.onerror = event => {
      reject(new Error(`getAll('${osName}'): ${event.target.error}`))
    }
    tr.oncomplete = event => {
      log(`getAll('${osName}'): transaction completed`)
    }

    let os = tr.objectStore(osName)
    let req = os.getAll()
    req.onerror = event => {
      reject(new Error(`datastore get request: ${event.target.error}`))
    }
    req.onsuccess = event => {
      resolve(req.result)
    }
  })
}

async function sendUpdateAccounts() {
  getAll('accounts').then(result => {
    send({
      msg: 'update accounts',
      accounts: result,
    })
  })
}

async function sendUpdateCategories() {
  getAll('categories').then(result => {
    send({
      msg: 'update categories',
      categories: result,
    })
  })
}

///////////////////////////////////////////////////////////////////////////////

let database = null

async function openDatabase() {
  return new Promise((resolve, reject) => {
    if (database !== null) {
      reject(new Error('internal error: database already opened'))
    }
    if (!indexedDB) {
      reject(new Error('IndexedDB not supported by browser'))
    }

    let req = indexedDB.open('Pactole', 1)
    req.onerror = event => {
      reject(new Error(`failed to open database: ${event.target.error}`))
    }
    req.onsuccess = event => {
      log('Database opened.')
      database = event.target.result
      database.onerror = event => {
        //TODO
        log(new Error(`database error: ${event.target.errorCode}`))
      }
      resolve()
    }

    req.onupgradeneeded = event => {
      log('Upgrading database...')
      const db = event.target.result

      db.createObjectStore('accounts', { keyPath: 'name' })
      db.createObjectStore('categories', { keyPath: 'name' })
      const os = db.createObjectStore('transactions', { autoIncrement: true })

      os.transaction.oncomplete = () => {
        {
          const os = db
            .transaction('accounts', 'readwrite')
            .objectStore('accounts')
          os.add({ name: 'Compte' })
        }

        {
          const os = db
            .transaction('categories', 'readwrite')
            .objectStore('categories')
          os.add({ name: 'Nourriture' })
          os.add({ name: 'Habillement' })
          os.add({ name: 'Maison' })
          os.add({ name: 'Santé' })
          os.add({ name: 'Loisirs' })
        }

        {
          const os = db
            .transaction('transactions', 'readwrite')
            .objectStore('transactions')
          dummyTransactions.forEach(t => {
            os.add(t)
          })
        }
      }
      log('...database upgraded.')
    }
  })
}

///////////////////////////////////////////////////////////////////////////////

const dummyAccounts = [
  {
    name: 'Mon Compte',
    kind: 'assets',
  },
]

const dummyCategories = [
  {
    name: "Entrée d'argent",
  },
  {
    name: 'Maison',
  },
  {
    name: 'Nourriture',
  },
  {
    name: 'Habillement',
  },
  {
    name: 'Transport',
  },
  {
    name: 'Santé',
  },
  {
    name: 'Loisirs',
  },
  {
    name: 'Autre',
  },
]

const dummyTransactions = [
  {
    date: '2019-05-02',
    amount: 50000,
    category: "Entrée d'argent",
    description: 'AAH',
    reconciled: false,
  },
  {
    date: '2019-05-02',
    amount: 20000,
    category: "Entrée d'argent",
    description: '',
    reconciled: false,
  },
  {
    date: '2019-05-03',
    amount: -56000,
    category: 'Loyer',
    description: '',
    reconciled: false,
  },
  {
    date: '2019-05-03',
    amount: -15000,
    category: 'Électricité',
    description: '',
    reconciled: false,
  },
  {
    date: '2019-05-03',
    amount: -3000,
    category: 'Téléphone',
    description: '',
    reconciled: false,
  },
  {
    date: '2019-05-05',
    amount: -2300,
    category: 'Santé',
    description: 'pharmacie',
    reconciled: false,
  },
  {
    date: '2019-05-09',
    amount: -700,
    category: 'Transports',
    description: '',
    reconciled: false,
  },
  {
    date: '2019-05-18',
    amount: -6000,
    category: 'Alimentation',
    description: 'courses Super U',
    reconciled: false,
  },
  {
    date: '2019-05-18',
    amount: -2000,
    category: 'Divers',
    description: 'distributeur',
    reconciled: false,
  },
  {
    date: '2019-05-20',
    amount: -3200,
    category: 'Habillement',
    description: 'La Halle aux Vêtements',
    reconciled: false,
  },
  {
    date: '2019-05-21',
    amount: -2000,
    category: 'Divers',
    description: 'distributeur',
    reconciled: false,
  },
  {
    date: '2019-05-23',
    amount: -5500,
    category: 'Transports',
    description: 'essence',
    reconciled: false,
  },
  {
    date: '2019-05-24',
    amount: -3500,
    category: 'Loisirs',
    description: 'Raspberry Pi',
    reconciled: false,
  },
  {
    date: '2019-06-01',
    amount: 50000,
    category: "Entrée d'argent",
    description: 'AAH',
    reconciled: false,
  },
  {
    date: '2019-06-02',
    amount: 20000,
    category: "Entrée d'argent",
    description: '',
    reconciled: false,
  },
  {
    date: '2019-06-02',
    amount: -2000,
    category: 'Divers',
    description: '',
    reconciled: false,
  },
  {
    date: '2019-06-03',
    amount: -56000,
    category: 'Loyer',
    description: 'Loyer',
    reconciled: false,
  },
  {
    date: '2019-06-03',
    amount: -3000,
    category: 'Téléphone',
    description: 'Facture téléphone',
    reconciled: false,
  },
  {
    date: '2019-06-11',
    amount: -800,
    category: 'Transports',
    description: '',
    reconciled: false,
  },
  {
    date: '2019-06-18',
    amount: -6500,
    category: 'Alimentation',
    description: 'courses Super U',
    reconciled: false,
  },
]
