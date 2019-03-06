import argparse
import csv
import cv2
import os
import requests
import shutil
import tempfile


class ImageLabeller(object):

    def __init__(self, csvfile, owner=None):
        self.fieldnames = ["auction_id", "image_key", "url", "brand", "owner"]
        self.tirePhotosCsvFile = csvfile
        self.owner = owner

    def fetchUniqueIds(self, csvfile):
        auctionId = set()
        if os.path.isfile(self.tirePhotosCsvFile):
            with open(self.tirePhotosCsvFile, "r") as fp:
                reader = csv.DictReader(fp, delimiter=",")
                for row in reader:
                    auctionId.add(int(row["auction_id"]))
        else:
            raise AssertionError("Csv file does not exist: {}".format(self.tirePhotosCsvFile))
        return auctionId

    def download(self, url, show=True):
        response = requests.get(url)
        name = url.split("/")[-1]
        if response.status_code == 200:
            # print("Downloading: {}".format(url))
            with open(name, "wb") as fp:
                fp.write(response.content)
            img = cv2.imread(name)
            if show:
                cv2.namedWindow(name, cv2.WINDOW_KEEPRATIO)
                cv2.imshow(name, img)
                cv2.waitKey(0)
                cv2.destroyAllWindows()
            return img
        else:
            print("Download failed for {}".format(url))
            return None

    def labelBrand(self):
        if os.path.isfile(self.tirePhotosCsvFile):
            try:
                tempFp = tempfile.NamedTemporaryFile("w", dir=os.getcwd(), delete=False, newline='')
                quit = False
                with open(self.tirePhotosCsvFile, "r") as fp, tempFp:
                    reader = csv.DictReader(fp, delimiter=",")
                    writer = csv.DictWriter(tempFp, fieldnames=self.fieldnames)
                    writer.writeheader()
                    for row in reader:
                        if self.owner == row["owner"]:
                            if quit or row["brand"]:
                                writer.writerow(row)
                            else:
                                img = self.download(row["url"], True)
                                if img is None:
                                    break
                                brand = input("Enter brand name for {}: ".format(row["auction_id"]))
                                if brand.strip() == "quit" or brand.strip() == "q":
                                    quit = True
                                else:
                                    row["brand"] = brand.strip()
                                writer.writerow(row)
                        else:
                            writer.writerow(row)
            finally:
                shutil.move(tempFp.name, self.tirePhotosCsvFile)
                tempFp.close()

    def showLabel(self):
        if os.path.isfile(self.tirePhotosCsvFile):
            with open(self.tirePhotosCsvFile, "r") as fp:
                reader = csv.DictReader(fp, delimiter=",")
                for row in reader:
                    if self.owner == row["owner"]:
                        img = self.download(row["url"], False)
                        if img is None:
                            break
                        brand = row["brand"] if row["brand"] else "Not labelled"
                        (width, height) = cv2.getTextSize(brand, cv2.FONT_HERSHEY_SIMPLEX,
                                                          fontScale=1, thickness=2)[0]
                        cv2.rectangle(img, (50, 50), (50 + width, 50 - height),
                                      (0, 255, 255), cv2.FILLED)
                        cv2.putText(img, brand, (50, 50), cv2.FONT_HERSHEY_SIMPLEX,
                                    fontScale=1, color=(0, 0, 255), thickness=2)
                        cv2.namedWindow("show", cv2.WINDOW_KEEPRATIO)
                        cv2.waitKey(0)
                        cv2.destroyWindow("show")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", choices=["akshay", "adityan", "roshini"], required=True)
    parser.add_argument("--labelImages", action="store_true")
    parser.add_argument("--showLabels", action="store_true")
    args, _ = parser.parse_known_args()
    filename = "tire_photos.csv"
    labelObj = ImageLabeller(filename, args.owner)
    if args.labelImages:
        print('Starting image labelling...')
        labelObj.labelBrand()
    elif args.showLabels:
        labelObj.showLabel()
    else:
        raise AssertionError("No valid option selected. check --help.")
