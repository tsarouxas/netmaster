#!/bin/bash
#fetches all publically available DNS information for a domain
dig +nocmd atvea.org any +multiline +noall +answer
