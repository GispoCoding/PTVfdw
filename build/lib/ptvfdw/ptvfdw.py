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
        # ENSIMMAINEN PTV APIIN LIITTYVA TESTI
        if "/GetCountryCodes" in self.urlop:
            try:
                for item in data:
                    ret = {'code': item['code']}
                    yield ret
            except KeyError:
                self.log("ptv FDW: Invalid JSON content")
                ret = {'code': None}
                yield ret
        elif "/GetMunicipalityCodes" in self.urlop:
            try:
                for item in data:
                    ret = {}
                    try:
                        ret.update({'code': item['code']})
                    except KeyError:
                        self.log("ptv FDW: Invalid JSON content")
                        ret.update({'code': None})
                    # try:
                    nimet = [(j['value']) for j in item['names']]
                    kielet = [(j['language']) for j in item['names']]
                    for k in range(len(kielet)):
                        if kielet[k] == "fi":
                            ret.update({'names_fi': nimet[k]})
                        elif kielet[k] == "sv":
                            ret.update({'names_sv': nimet[k]})
                        elif kielet[k] == "en":
                            ret.update({'names_en': nimet[k]})
                        # ret.update({'names': list(set([j['value'] for j in item['names']]))})
                        # ret.update({'names': list(set([(j['language'] + ":" + j['value']) for j in item['names']]))})
                    # except KeyError:
                    # self.log("ptv FDW: Invalid JSON content")
                    # ret.update({'namesFi': None, 'namesSv': None, 'namesEng': None})
                    yield ret
            except KeyError:
                self.log("ptv FDW: Invalid JSON content")
                ret = {'code': None, 'names_fi': None, 'names_sv': None, 'names_en': None}
                yield ret
        elif "/Organization" in self.urlop and len(self.urlop) < 65:
            try:
                for item in data['itemList']:
                    ret = {'org_id': item['id'], 'org_name': item['name']}
                    yield ret
            except KeyError:
                self.log("ptv FDW: Invalid JSON content")
                ret = {'org_id': None, 'org_name': None}
                yield ret
        # Kaikki Varsinais-Suomen kuntien palvelut IDeineen
        elif "/Service/list/area/Municipality/code/" in self.urlop:
            data2 = self.get_data2(quals, columns)
            li2 = list()
            li3 = list()
            for item in data2['itemList'][1]['areas']:
                koodit = [(j['code']) for j in item['municipalities']]
                nimet = [(j['name']) for j in item['municipalities']]
                for k in range(len(koodit)):
                    li2.append(koodit[k])
                    li3.append(nimet[k][2]['value'])
            for u in range(len(li2)):
                # testataan vain Uudenkaupungin servicien hakua eka JOS if aktiivinen, sisennykset kuntoon!
                if li2[u] == '833' or li2[u] == '529' or li2[u] == '853' or li2[u] == '680':
                    self.urlop = "https://api.palvelutietovaranto.suomi.fi/api/v11/Service/list/area/Municipality/code/" + str(
                        li2[u])
                    data = self.get_data(quals, columns)
                    ret = {}
                    pages = int(data['pageCount'])
                    for j in range(1, pages + 1):
                        self.urlop = "https://api.palvelutietovaranto.suomi.fi/api/v11/Service/list/area/Municipality/code/" + str(
                            li2[u]) + "?page=" + str(j)
                        data = self.get_data(quals, columns)
                        for item in data['itemList']:
                            # self.log("taalla 1")
                            li4 = list()
                            li5 = list()
                            for item3 in item['serviceChannels']:
                                li4.append(item3['serviceChannel']['id'])
                                li5.append(item3['serviceChannel']['name'])
                            for d in range(len(li4)):
                                try:
                                    ret.update({'channel_id': li4[d]})
                                except KeyError:
                                    self.log("ptv FDW: Invalid JSON content")
                                    ret.update({'channel_id': None})
                                try:
                                    ret.update({'channel_nimi': li5[d]})
                                except KeyError:
                                    self.log("ptv FDW: Invalid JSON content")
                                    ret.update({'channel_nimi': None})
                                try:
                                    ret.update({'service_id': item['id']})
                                except KeyError:
                                    self.log("ptv FDW: Invalid JSON content")
                                    ret.update({'service_id': None})
                                try:
                                    ret.update({'kunta_koodi': li2[u]})
                                except KeyError:
                                    self.log("ptv FDW: Invalid JSON content")
                                    ret.update({'kunta_koodi': None})
                                try:
                                    ret.update({'kunta_nimi': li3[u]})
                                except KeyError:
                                    self.log("ptv FDW: Invalid JSON content")
                                    ret.update({'kunta_nimi': None})
                                try:
                                    catli = [(t['value']) for t in item['serviceNames'] if t['language'] == "fi"]
                                    for r in range(len(catli)):
                                        if r == 0:
                                            catstr = catli[r]
                                        else:
                                            catstr = catstr + ', ' + catli[r]
                                    ret.update({'kategoria': catstr})
                                    # vanha tapa, toimi myos jos listamuoto kelpaa
                                    # ret.update({'kategoria': [(t['value']) for t in item['serviceNames']]})
                                except KeyError:
                                    self.log("ptv FDW: Invalid JSON content")
                                    ret.update({'kategoria': None})
                                yield ret
        # yo. vastaavan voisi yrittaa koodata siten, etta hakee ServiceChannel/list/area/municipality
        # ja lisaisi sen sisallot omaan foreign tableen jotka sitten liittaisi sqllla samaan tauluun?
        elif "/Organization/list/area/Province/code/02" in self.urlop:
            try:
                #
                # ret = {'mun_id': data['itemList'][1]['id']}
                # ret = {'mun_id': data['itemList'][1]['areas'][0]['municipalities'][0]['code']}
                # yield ret
                #
                li = list()
                nili = list()
                for item in data['itemList'][1]['areas']:
                    # ret = {}
                    koodit = [(j['code']) for j in item['municipalities']]
                    nimet = [(j['name']) for j in item['municipalities']]
                    # nimet = [(j['value']) for j in item['name']]
                    # kielet = [(j['language']) for j in item['name']]
                    for k in range(len(koodit)):
                        li.append(koodit[k])
                        nili.append(nimet[k][2]['value'])
                        # listankin voi suoraan heittaa postgis tauluun
                        # ret.update({'mun_id': li})
                        # yield ret
                ret = {}
                for u in range(len(li)):
                    ret.update({'mun_id': li[u], 'mun_name_fi': nili[u]})
                    yield ret
            except KeyError:
                self.log("ptv FDW: Invalid JSON content")
                ret = {'mun_id': None}
                yield ret
        # Tama on viela jaanne snowplowsta
        else:
            for item in data:
                ret = {}
                try:
                    ret.update({'id': item['id']})
                except KeyError:
                    self.log("ptv FDW: Invalid JSON content")
                    ret.update({'id': None})
                try:
                    ret.update({'machine_type': item['machine_type']})
                except KeyError:
                    self.log("ptv FDW: Invalid JSON content")
                    ret.update({'machine_type': None})
                try:
                    ret.update({'last_timestamp': item['last_location']['timestamp']})
                except KeyError:
                    self.log("ptv FDW: Invalid JSON content")
                    ret.update({'last_timestamp': None})
                try:
                    ret.update({'last_coords': item['last_location']['coords']})
                except KeyError:
                    self.log("ptv FDW: Invalid JSON content")
                    ret.update({'last_coords': None})
                try:
                    ret.update({'last_events': item['last_location']['events']})
                except KeyError:
                    self.log("ptv FDW: Invalid JSON content")
                    ret.update({'last_events': None})
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