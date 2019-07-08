'use strict'

import * as calendar from './calendar.js'
import * as ledger from './ledger.js'
import * as page from './page.js'

function id(id) {
  return document.getElementById(id)
}

if (!('serviceWorker' in navigator)) {
  console.error('FATAL: Service workers are not supported by the navigator.')
  throw new Error('FATAL: Service workers are not supported by the navigator.')
}

/*
navigator.storage.persist().then(persisted => {
  if (persisted) {
    console.log('Persistent storage allowed.')
    navigator.storage.estimate().then(info => {
      console.log(
        `Persistent usage: ${Math.round(
          info.usage / 1024,
        )}kb (quota: ${Math.round(info.quota / 1024)}kb).`,
      )
    })
  } else {
    console.error('*** NOT Persisted! ***')
  }
})
*/

onload = () => {
  navigator.serviceWorker
    .register('/service.js')
    .then(registration => {
      if (registration.installing) {
        console.log(
          `Service registration: installing (scope: ${registration.scope})`,
        )
      } else if (registration.waiting) {
        console.log(
          `Service registration: waiting (scope: ${registration.scope})`,
        )
      } else if (registration.active) {
        console.log(
          `Service registration: active (scope: ${registration.scope})`,
        )
      }
      registration.onupdatefound = () => {
        let w = registration.installing
        console.log(`A new service is being installed...`)
        w.onstatechange = event => {
          if (event.target.state === 'installed') {
            console.log(`The new service has been installed.`)
          }
        }
      }
    })
    .catch(err => {
      console.error(`Service registration failed: ${err}`)
    })
}

//navigator.serviceWorker.startMessages()

navigator.serviceWorker.ready
  .then(registration => {
    console.log(`Starting application...`)
    setupService(registration.active)
    const accounts = ledger.getAccounts()
    history.replaceState(
      {
        account: accounts[0],
        mode: 'calendar',
        month: calendar.thismonth(),
        day: calendar.today(),
      },
      'Pactole',
    )
    ledger.open(accounts[0].name).then(() => {
      page.renderAccounts()
      page.renderCategories()
      ledger.updateTransactions().then(() => {
        page.render()
      })
      wireHTML()
    })
  })
  .catch(err => {
    console.error(`Service worker not ready: ${err}`)
  })

///////////////////////////////////////////////////////////////////////////////

function wireHTML() {
  window.onpopstate = () => {
    console.log(`*** POPSTATE: ${window.location.pathname} ***`)
    page.render()
  }

  window.addEventListener('keydown', e => {
    switch (e.keyCode) {
      case 9: // Tab
        document.body.classList.toggle('keyboard-navigation', true)
        break
    }
  })

  window.addEventListener('mousedown', e => {
    document.body.classList.toggle('keyboard-navigation', false)
  })

  id('accounts').oninput = event => {
    const a = document.forms['accounts'].elements['account'].value
    console.log(`Switch to account ${a}`)
    ledger.open(a).then(() => {
      page.renderCategories()
      ledger.updateTransactions().then(() => {
        page.replaceState({ update: true })
      })
    })
  }

  id('list-income').onclick = () => {
    page.replaceState({ dialog: 'income' })
  }

  id('list-expense').onclick = () => {
    page.replaceState({ dialog: 'expense' })
  }

  id('calendar-income').onclick = () => {
    page.replaceState({ dialog: 'income' })
  }

  id('calendar-expense').onclick = () => {
    page.replaceState({ dialog: 'expense' })
  }

  id('dialog-cancel').onclick = event => {
    //event.preventDefault()
    page.replaceState({ dialog: null })
  }

  id('dialog').onclick = e => {
    if (e.target == id('dialog')) {
      page.replaceState({ dialog: null })
    }
  }

  id('dialog-confirm').onclick = event => {
    //event.preventDefault()
    const f = document.forms['dialog-form']
    const transac = {
      date: f['date'].value,
      amount: 100 * f['amount'].value,
      description: f['description'].value,
      category: f['category'].value,
      reconciled: false,
    }
    if (id('dialog').classList.contains('expense')) {
      transac.amount = -transac.amount
    }
    ledger.addTransaction(transac).then(() => {
      send('new transaction')
    })
    page.replaceState({ dialog: null })
  }

  id('nav-settings').onclick = () => {
    page.replaceState({ settings: true })
  }

  id('settings').onclick = e => {
    if (e.target == id('settings')) {
      page.replaceState({ settings: null })
    }
  }

  id('mode-0').oninput = e => {
    page.pushState({ mode: 'calendar' })
  }

  id('mode-1').oninput = e => {
    page.pushState({ mode: 'list' })
  }

  id('settings-categories-toggle-0').oninput = e => {
    id('categories-section').hidden = true
  }

  id('settings-categories-toggle-1').oninput = e => {
    id('categories-section').hidden = false
  }
}

///////////////////////////////////////////////////////////////////////////////

let service = null

function setupService(s) {
  service = s
  navigator.serviceWorker.onmessage = event => {
    console.log(`Received ${event.data.title}.`)
    switch (event.data.title) {
      case 'accounts':
        page.renderAccounts()
        break

      case 'categories':
        page.renderCategories()
        break

      case 'transactions':
        ledger.updateTransactions().then(() => {
          page.replaceState({ update: true })
        })
        break
    }
  }
}

function send(title, content) {
  console.log(`Sending ${title} to service...`)
  return service.postMessage({ title: title, content: content })
}

///////////////////////////////////////////////////////////////////////////////

function readSettings() {
  const settings = localStorage.getItem('settings')
  if (!settings) {
    settings = defaultSettings
    localStorage.setItem('settings', JSON.stringify(settings))
  } else {
    settings = JSON.parse(settings)
  }
  return settings
}
