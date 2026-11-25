// Arma la carpeta web/ con tu juego de Wollok corriendo 100% en el navegador.
//
// Uso (desde la raíz del proyecto, donde está package.json):
//   node build-web.mjs            -> genera web/
//   node build-web.mjs --serve    -> genera web/ y la sirve en http://localhost:8765
//
// Requisito: tener wollok-ts-cli instalado globalmente (npm i -g wollok-ts-cli).
// De ahí se copia el runtime web (p5 + wollok-ts + LocalGame).
// Si lo tenés en otro lado: WOLLOK_RUNTIME=/ruta/a/game/lib node build-web.mjs

import { execSync } from 'node:child_process'
import fs from 'node:fs'
import http from 'node:http'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const raiz = path.dirname(fileURLToPath(import.meta.url))
const salida = path.join(raiz, 'docs')
const plantilla = path.join(raiz, 'web-src')

const EXT_FUENTES = ['.wlk', '.wpgm']
const EXT_SONIDOS = ['.mp3', '.ogg', '.wav']
const EXT_ASSETS = ['.png', '.jpg', '.jpeg', '.gif', '.webp', ...EXT_SONIDOS]
const CARPETAS_IGNORADAS = new Set(['node_modules', '.git', '.history', '.vscode', 'log', 'docs', 'web-src'])

const buscarRuntime = () => {
  const candidatos = [
    process.env.WOLLOK_RUNTIME,
    path.join(execSync('npm root -g').toString().trim(), 'wollok-ts-cli', 'dist', 'public', 'game', 'lib'),
    path.join(raiz, 'node_modules', 'wollok-ts-cli', 'dist', 'public', 'game', 'lib'),
  ].filter(Boolean)
  const lib = candidatos.find(c => fs.existsSync(path.join(c, 'game-index.js')))
  if (!lib) {
    throw new Error(
      'No encontré el runtime de Wollok Game. Instalalo con "npm i -g wollok-ts-cli" ' +
      'o indicá la carpeta con WOLLOK_RUNTIME.\nBusqué en:\n  ' + candidatos.join('\n  ')
    )
  }
  return lib
}

const recorrer = (dir, base = dir) =>
  fs.readdirSync(dir, { withFileTypes: true }).flatMap(entrada => {
    const completa = path.join(dir, entrada.name)
    if (entrada.isDirectory()) return CARPETAS_IGNORADAS.has(entrada.name) ? [] : recorrer(completa, base)
    return [path.relative(base, completa).split(path.sep).join('/')]
  })

const copiar = (desde, hasta) => {
  fs.mkdirSync(path.dirname(hasta), { recursive: true })
  fs.copyFileSync(desde, hasta)
}

const esSonido = f => EXT_SONIDOS.includes(path.extname(f).toLowerCase())
const medio = f => ({ possiblePaths: [f], url: `assets/${f.split('/').map(encodeURIComponent).join('/')}` })

const construir = () => {
  const paquete = JSON.parse(fs.readFileSync(path.join(raiz, 'package.json'), 'utf8'))
  const carpetaAssets = paquete.resourceFolder ?? 'assets'

  const fuentes = recorrer(raiz)
    .filter(f => EXT_FUENTES.includes(path.extname(f)))
    .map(name => ({ name, content: fs.readFileSync(path.join(raiz, name), 'utf8') }))

  const programas = fuentes.filter(f => f.name.endsWith('.wpgm'))
  if (programas.length !== 1) throw new Error(`Se esperaba exactamente 1 archivo .wpgm y hay ${programas.length}`)
  const main = programas[0].name.replace(/\.wpgm$/, '').replace(/\//g, '.')

  const dirAssets = path.join(raiz, carpetaAssets)
  const assets = fs.existsSync(dirAssets)
    ? recorrer(dirAssets).filter(f => EXT_ASSETS.includes(path.extname(f).toLowerCase()))
    : []

  fs.rmSync(salida, { recursive: true, force: true })
  fs.mkdirSync(path.join(salida, 'lib'), { recursive: true })

  const runtime = buscarRuntime()
  for (const f of ['p5.min.js', 'p5.sound.min.js', 'game-index.js']) {
    copiar(path.join(runtime, f), path.join(salida, 'lib', f))
  }
  for (const f of fs.readdirSync(plantilla)) copiar(path.join(plantilla, f), path.join(salida, f))
  for (const a of assets) copiar(path.join(dirAssets, a), path.join(salida, 'assets', a))
  fs.writeFileSync(path.join(salida, '.nojekyll'), '')

  const proyecto = {
    main,
    sources: fuentes,
    description: '',
    images: assets.filter(f => !esSonido(f)).map(medio),
    sounds: assets.filter(esSonido).map(medio),
  }
  fs.writeFileSync(path.join(salida, 'game.json'), JSON.stringify(proyecto))

  console.log(`✔ web/ lista: ${fuentes.length} fuentes, ${assets.length} assets, programa ${main}`)
  avisarFaltantes(fuentes, assets)
}

// Busca en el código nombres de imagen/sonido escritos entre comillas y avisa los que no están en assets/.
const avisarFaltantes = (fuentes, assets) => {
  const existentes = new Set(assets)
  const patron = /"([^"\n]+\.(?:png|jpe?g|gif|webp|mp3|ogg|wav))"/gi
  const faltantes = new Set()
  for (const { content } of fuentes) {
    for (const m of content.matchAll(patron)) if (!existentes.has(m[1])) faltantes.add(m[1])
  }
  if (faltantes.size === 0) return
  console.warn(`\n⚠ Faltan ${faltantes.size} archivos en assets/ (el juego los pide, pero no los encontré):`)
  for (const f of [...faltantes].sort()) console.warn('   - ' + f)
  console.warn('  Copialos a assets/ y volvé a correr el script.\n')
}

const MIME = {
  '.html': 'text/html; charset=utf-8', '.css': 'text/css; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
  '.gif': 'image/gif', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.ogg': 'audio/ogg', '.wav': 'audio/wav',
}

const servir = (puerto = 8765) => {
  http.createServer((req, res) => {
    const ruta = decodeURIComponent(new URL(req.url, 'http://x').pathname)
    const archivo = path.join(salida, ruta.endsWith('/') ? ruta + 'index.html' : ruta)
    if (!archivo.startsWith(salida) || !fs.existsSync(archivo) || fs.statSync(archivo).isDirectory()) {
      res.writeHead(404).end('No encontrado')
      return
    }
    res.writeHead(200, { 'Content-Type': MIME[path.extname(archivo).toLowerCase()] ?? 'application/octet-stream' })
    fs.createReadStream(archivo).pipe(res)
  }).listen(puerto, () => console.log(`Abrí http://localhost:${puerto}`))
}

try {
  construir()
  if (process.argv.includes('--serve')) servir()
} catch (error) {
  console.error('✘ ' + error.message)
  process.exit(1)
}
