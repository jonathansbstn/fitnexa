import urllib.request
import re

def get_lottie(query):
    url = f'https://lottiefiles.com/search?q={query}&category=animations'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        html = urllib.request.urlopen(req).read().decode('utf-8')
        # Lottiefiles now uses different formats, let's look for any .json url
        matches = re.findall(r'(https://[^"\'\\]+\.json)', html)
        if matches:
            for m in matches:
                if 'lottie' in m: return m
            return matches[0]
    except Exception as e:
        pass
    return None

print('Workout:', get_lottie('workout'))
print('Chart:', get_lottie('chart'))
print('Trophy:', get_lottie('trophy'))
print('Fire:', get_lottie('fire'))
print('Loading:', get_lottie('loading'))
