"""Add missing local authentication secrets without printing or replacing them."""
from pathlib import Path
import re
import secrets

path = Path(__file__).resolve().parents[1] / 'archive_server/config/passwords.yaml'
text = path.read_text()
for mode in ('development', 'test'):
    match = re.search(rf'(?m)^{mode}:\s*$', text)
    if not match:
        text += f'\n{mode}:\n'
        match = re.search(rf'(?m)^{mode}:\s*$', text)
    end_match = re.search(r'(?m)^\w[^\n]*:', text[match.end():])
    end = match.end() + end_match.start() if end_match else len(text)
    block = text[match.end():end]
    additions = ''
    for key in ('jwtHmacSha512PrivateKey', 'jwtRefreshTokenHashPepper', 'emailSecretHashPepper'):
        if not re.search(rf'(?m)^\s+{key}:', block):
            additions += f'  {key}: {secrets.token_urlsafe(64)}\n'
    if additions:
        text = text[:end].rstrip() + '\n' + additions + '\n' + text[end:]
path.write_text(text)
path.chmod(0o600)
print('Local authentication secrets configured; existing values preserved.')
