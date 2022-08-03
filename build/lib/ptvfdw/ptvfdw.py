import requests
import re

from multicorn import ForeignDataWrapper
from multicorn.utils import log_to_postgres
from logging import ERROR, INFO, WARNING


class ForeignDataWrapperError(Exception):

    def __init__(self, message):
        log_to_postgres(message, ERROR)


class MissingOptionError(ForeignDataWrapperError):

    def __init__(self, option):
        message = f"Missing option {option}"
        super(MissingOptionError, self).__init__(message)


class OptionTypeError(ForeignDataWrapperError):

    def __init__(self, option, option_type):
        message = f"Option {option} is not of type {option_type}"
        super(OptionTypeError, self).__init__(message)


class ptvForeignDataWrapper(ForeignDataWrapper):

    def __init__(self, options, columns):
        super(ptvForeignDataWrapper, self).__init__(options, columns)
        self.options = options
        self.columns = columns
        self.urlop = self.get_option("url")
        try:
            self.url = self.urlop
        except ValueError as e:
            self.log("Invalid url value {}".format(options.get("url", "")))
            raise e

    def execute(self, quals, columns):
        data = self.get_data(quals, columns)
        # Kuntakoodit
        if "/GetMunicipalityCodes" in self.urlop:
            try:
                for item in data:
                    ret = {}
                    try:
                        ret.update({'code': item['code']})
                    except KeyError:
                        self.log("ptv FDW: Invalid JSON content")
                        ret.update({'code': None})
                    nimet = [(j['value']) for j in item['names']]
                    kielet = [(j['language']) for j in item['names']]
                    for k in range(len(kielet)):
                        if kielet[k] == "fi":
                            ret.update({'names_fi': nimet[k]})
                        elif kielet[k] == "sv":
                            ret.update({'names_sv': nimet[k]})
                        elif kielet[k] == "en":
                            ret.update({'names_en': nimet[k]})
                    yield ret
            except KeyError:
                self.log("ptv FDW: Invalid JSON content")
                ret = {'code': None, 'names_fi': None, 'names_sv': None, 'names_en': None}
                yield ret
        # Versio joka tulostaa kaikki VS-suomen ja satakunnan serviceIdt, servicenamet ja niihin kuuluvien serviceclass nimet!
        elif "/Service/list/area/Municipality/code/" in self.urlop:
            data2 = self.get_data2(quals, columns)
            li2 = list()
            for item in data2['itemList'][1]['areas']:
                koodit = [(j['code']) for j in item['municipalities']]
                for k in range(len(koodit)):
                    li2.append(koodit[k])
            for u in range(len(li2)):
                self.urlop = "https://api.palvelutietovaranto.suomi.fi/api/v11/Service/list/area/Municipality/code/" + str(li2[u])
                data = self.get_data(quals, columns)
                ret = {}
                pages = int(data['pageCount'])
                for j in range(1, pages + 1):
                    self.urlop = "https://api.palvelutietovaranto.suomi.fi/api/v11/Service/list/area/Municipality/code/" + str(li2[u]) + "?page=" + str(j)
                    data = self.get_data(quals, columns)
                    for item in data['itemList']:
                            try:
                                ret.update({'service_id': item['id']})
                                #self.log(item['id'])
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'service_id': None})
                            try:
                                luokat = list()
                                if item.get('serviceClasses') == None:
                                    self.log("ongelmia")
                                    self.log(stop)
                                else:
                                    for item7 in item['serviceClasses']:
                                        luokka = [(t['value']) for t in item7['name'] if t['language'] == "fi"][0]
                                        luokat.append(luokka)
                                    for r in range(len(luokat)):
                                        if r == 0:
                                            luokstr = luokat[r]
                                        else:
                                            luokstr = luokstr + ', ' + luokat[r]
                                    ret.update({'serviceclass': luokstr})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'serviceclass': None})
                            try:
                                if item.get('serviceNames') == None:
                                    self.log("ongelmia2")
                                    self.log(stop)
                                else:
                                    nimet = [(t['value']) for t in item['serviceNames'] if t['language'] == "fi"]
                                    for r in range(len(nimet)):
                                        if r == 0:
                                            nimistr = nimet[r]
                                        else:
                                            nimistr = nimistr + ', ' + nimet[r]
                                    ret.update({'servicename': nimistr})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'servicename': None})
                            yield ret
        # VS-Suomen ja Satakunnan organisaatiolistaus
        elif "/Organization/list/area/Province/code/02" in self.urlop:
            try:
                li = list()
                nili = list()
                for item in data['itemList'][1]['areas']:
                    koodit = [(j['code']) for j in item['municipalities']]
                    nimet = [(j['name']) for j in item['municipalities']]
                    for k in range(len(koodit)):
                        li.append(koodit[k])
                        nili.append(nimet[k][2]['value'])
                ret = {}
                for u in range(len(li)):
                    ret.update({'mun_id': li[u], 'mun_name_fi': nili[u]})
                    yield ret
            except KeyError:
                self.log("ptv FDW: Invalid JSON content")
                ret = {'mun_id': None}
                yield ret
        # Oletusarvoinen toiminta, esim urlin https://api.palvelutietovaranto.suomi.fi/api/v11/ServiceChannel/list/area/Municipality/code/529?page=1 tiedot
        # VAIHTOEHTOISESTI
        # elif "/ServiceChannel/list/area/Municipality/code/" in self.urlop:
        # ja elseen jotain muuta
        else:
            data2 = self.get_data2(quals, columns)
            li2 = list()
            for item in data2['itemList'][1]['areas']:
                koodit = [(j['code']) for j in item['municipalities']]
                for k in range(len(koodit)):
                    li2.append(koodit[k])
                    # jos tarvii testata nopeasti jotain
                    # if koodit[k]=='761':
                    # li2.append(koodit[k])
            for p in range(len(li2)):
                self.urlop = "https://api.palvelutietovaranto.suomi.fi/api/v11/ServiceChannel/list/area/Municipality/code/" + str(
                    li2[p])
                data = self.get_data(quals, columns)
                ret = {}
                pages = int(data['pageCount'])
                for l in range(1, pages + 1):
                    self.urlop = "https://api.palvelutietovaranto.suomi.fi/api/v11/ServiceChannel/list/area/Municipality/code/" + str(
                        li2[p]) + "?page=" + str(l)
                    data = self.get_data(quals, columns)
                    for item in data['itemList']:
                        # self.log("taalla 1")
                        if item['serviceChannelType'] == "ServiceLocation":
                            # servicejen nimet
                            try:
                                seidli = [(s['service']['name']) for s in item['services']]
                            except:
                                seidli = ["-"]
                            # palvelupisteen nimi
                            try:
                                nimi = [(t['value']) for t in item['serviceChannelNames'] if t['language'] == "fi"][0]
                            except:
                                nimi = "-"
                            # koordinaatit ja osoite
                            for item2 in item['addresses']:
                                if item2['type'] == "Location":
                                    try:
                                        lat = item2['streetAddress']['latitude']
                                    except:
                                        lat = None
                                    try:
                                        lon = item2['streetAddress']['longitude']
                                    except:
                                        lon = None
                                    try:
                                        postinro = item2['streetAddress']['postalCode']
                                    except:
                                        postinro = "ei"
                                    try:
                                        katunum = item2['streetAddress']['streetNumber']
                                    except:
                                        katunum = "ei"
                                    try:
                                        katu = [(h['value']) for h in item2['streetAddress']['street'] if
                                                h['language'] == "fi"][0]
                                    except:
                                        katu = "ei"
                                    try:
                                        postipaik = [(h['value']) for h in item2['streetAddress']['postOffice'] if
                                                     h['language'] == "fi"][0]
                                    except:
                                        postipaik = "ei"
                                    if katu != "ei" and katunum != "ei" and postinro != "ei" and postipaik != "ei":
                                        osoite = katu + ' ' + katunum + ', ' + postinro + ' ' + postipaik
                                    else:
                                        self.log("Incomplete address information available.")
                                        osoite = "-"
                            puhli1 = [s['prefixNumber'] for s in item['phoneNumbers'] if
                                      isinstance(s['prefixNumber'], str)]
                            puhli2 = [s['number'] for s in item['phoneNumbers'] if isinstance(s['number'], str)]
                            if len(puhli1) == len(puhli2):
                                puhli = [m + str(n) for m, n in zip(puhli1, puhli2)]
                            else:
                                puhli = []
                            if len(puhli) == 0:
                                puhstr = "-"
                            else:
                                for b in range(len(puhli)):
                                    if b == 0:
                                        puhstr = puhli[b]
                                    else:
                                        puhstr = puhstr + '; ' + puhli[b]
                            # spostiosoitteet
                            mailli = [(s['value']) for s in item['emails'] if
                                      (s['language'] == "fi" and isinstance(s['value'], str))]
                            if len(mailli) == 0:
                                mailstr = "-"
                            else:
                                for c in range(len(mailli)):
                                    if c == 0:
                                        mailstr = mailli[c]
                                    else:
                                        mailstr = mailstr + '; ' + mailli[c]
                            # verkkosivut
                            webli = [(r['url']) for r in item['webPages'] if (r['language'] == "fi" and isinstance(r['url'], str))]
                            if len(webli) == 0:
                                webstr = "-"
                            else:
                                for c in range(len(webli)):
                                    if c == 0:
                                        webstr = webli[c]
                                    else:
                                        webstr = webstr + '; ' + webli[c]
                            # aukioloajat
                            aukistr = "-"
                            for item3 in item['serviceHours']:
                                if item3['serviceHourType'] == "DaysOfTheWeek":
                                    paiva1 = [(h['dayFrom']) for h in item3['openingHour']]
                                    paiva2 = [(h['dayTo']) for h in item3['openingHour']]
                                    tunti1 = [(h['from']) for h in item3['openingHour']]
                                    tunti2 = [(h['to']) for h in item3['openingHour']]
                            for d in range(len(tunti1)):
                                if isinstance(paiva1[d], str) and isinstance(paiva2[d], str) and isinstance(
                                        tunti1[d], str) and isinstance(tunti2[d], str):
                                    if d == 0:
                                        aukistr = paiva1[d] + '-' + paiva2[d] + ': ' + tunti1[d] + '-' + tunti2[d]
                                    else:
                                        aukistr = aukistr + '; ' + (paiva1[d] + '-' + paiva2[d] + ': ' + tunti1[d] + '-' + tunti2[d])
                            if aukistr == "-":
                                self.log("Incomplete opening hour information available.")
                            aukistr = str(aukistr).replace("-:", ":")
                            # taulun paivitys
                            try:
                                ret.update({'orig_id': item['id']})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'orig_id': None})
                            try:
                                ret.update({'palvelut': seidli})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'palvelut': None})
                            try:
                                ret.update({'kohteen_nimi': nimi})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'kohteen_nimi': None})
                            try:
                                ret.update({'latitude': lat})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'latitude': None})
                            try:
                                ret.update({'longitude': lon})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'longitude': None})
                            try:
                                ret.update({'osoite': osoite})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'osoite': None})
                            try:
                                ret.update({'puhelinnumero': puhstr})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'puhelinnumero': None})
                            try:
                                ret.update({'sahkoposti': mailstr})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'sahkoposti': None})
                            try:
                                ret.update({'verkkosivu': webstr})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'verkkosivu': None})
                            try:
                                ret.update({'aukioloajat': aukistr})
                            except KeyError:
                                self.log("ptv FDW: Invalid JSON content")
                                ret.update({'aukioloajat': None})
                            yield ret


    def get_data(self, quals, columns):
        url = self.urlop
        return self.fetch(url)

    def get_data2(self, quals, columns):
        self.urlop = "https://api.palvelutietovaranto.suomi.fi/api/v11/Organization/list/area/Province/code/02"
        url = self.urlop
        return self.fetch(url)

    def fetch(self, url):
        self.log("URL is: {}".format(url), INFO)
        try:
            response = requests.get(url)
        except requests.exceptions.ConnectionError as e:
            self.log("ptv FDW: unable to connect to {}".format(url))
            return []
        except requests.exceptions.Timeout as e:
            self.log("ptv FDW: timeout connecting to {}".format(url))
            return []
        if response.ok:
            try:
                return response.json()
            except ValueError as e:
                self.log("ptv FDW: invalid JSON")
                return []
        else:
            self.log("ptv FDW: server returned status code {} with text {} for url {}".format(response.status_code,
                                                                                              response.text, url))
            return []

    def get_option(self, option, required=True, default=None, option_type=str):
        if required and option not in self.options:
            raise MissingOptionError(option)
        value = self.options.get(option, default)
        if value is None:
            return None
        try:
            return option_type(value)
        except ValueError as e:
            raise OptionTypeError(option, option_type)

    def log(self, message, level=WARNING):
        log_to_postgres(message, level)