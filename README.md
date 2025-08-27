# Utilities per l'immagine siberio-ops

Questo repository contiene utilità e script usati nell'immagine `siberio-ops`.

## scripts/scale-deployments.sh

Script Bash che scala tutti i `Deployment` e i `StatefulSet` in uno o più namespace selezionati.

Caratteristiche principali:
- Selezione dei namespace tramite label `scalable=true` (default) oppure tramite `-n ns1,ns2`.
- Opera su `Deployment` e `StatefulSet`, saltando le risorse gestite da un `HorizontalPodAutoscaler` (HPA).
- Scala impostando un numero assoluto di repliche tramite `--replicas N` (obbligatorio). Supporta `--dry-run`.

Requisiti
- `kubectl` configurato e accesso al cluster.
- `jq` disponibile nel PATH.

Uso

```bash
# imposta esattamente 0 repliche in tutti i namespace con label scalable=true (dry-run)
./scripts/scale-deployments.sh --replicas 0 --dry-run

# imposta esattamente 1 replica per i namespace default e tools
./scripts/scale-deployments.sh -n default,tools --replicas 1

# imposta 3 repliche usando un contesto kubectl specifico
./scripts/scale-deployments.sh --context my-cluster --replicas 3
```

Opzioni
- `-n, --namespaces`  lista comma-separata di namespace (se fornita bypassa la ricerca per label)
- `--replicas`        imposta un numero assoluto di repliche per tutti i deployment e statefulset (obbligatorio)
- `--context`         passa `--context <name>` a `kubectl`
- `--dry-run`         esegue una simulazione client-side (non modifica il cluster)
- `-h, --help`        mostra l'help

Comportamenti importanti
- Le risorse (Deployment/StatefulSet) gestite da un HPA vengono saltate per evitare conflitti con l'autoscaler.
- Se `.spec.replicas` è `null`, lo script lo tratta come `1` per i calcoli.
- Consigliato: eseguire prima con `--dry-run` per verificare le modifiche.

Permessi
Assicurati che lo script sia eseguibile:

```bash
chmod +x scripts/scale-deployments.sh
```

Licenza
Questo repository non specifica una licenza; applica le policy del progetto che lo usa.

---

Se vuoi, posso rendere lo script eseguibile automaticamente e aggiungere un piccolo test di smoke che esegue un `--dry-run` su un namespace fittizio. Vuoi che proceda?
